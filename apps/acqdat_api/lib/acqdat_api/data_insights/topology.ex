defmodule AcqdatApi.DataInsights.Topology do
  alias AcqdatCore.Model.EntityManagement.Project, as: ProjectModel
  alias AcqdatCore.Model.EntityManagement.SensorType, as: SensorTypeModel
  alias AcqdatCore.Model.EntityManagement.AssetType, as: AssetTypeModel
  alias AcqdatApiWeb.DataInsights.TopologyEtsConfig
  alias AcqdatApi.DataInsights.FactTableServer
  alias AcqdatCore.Model.DataInsights.FactTables
  alias AcqdatApi.DataStructure.Trees.NaryTree
  alias AcqdatCore.Repo
  alias Ecto.Multi

  def entities(data) do
    sensor_types = SensorTypeModel.get_all(data)
    asset_types = AssetTypeModel.get_all(data)
    %{topology: %{sensor_types: sensor_types || [], asset_types: asset_types || []}}
  end

  # NOTE: 1. gen_topology will parse tree hirerachy
  #       2. It'll generate parent tree map
  #       3. It'll save the parent tree map to ETS table
  def gen_topology(org_id, project) do
    proj_key = project |> ets_proj_key()
    data = proj_key |> TopologyEtsConfig.get()

    # Note: if value is not there for the respective proj_key in ets table, then do following things:
    # 1. fetch project topology
    # 2. set fetched project topology to ets table, with key being project_id + project_version
    if data != [] do
      [{_, tree}] = data
      tree
    else
      topology_map = ProjectModel.gen_topology(org_id, project)
      TopologyEtsConfig.set(proj_key, topology_map)
    end
  end

  # NOTE: 1. gen_sub_topology will update fact_table with user provided inputs
  #       2. It'll pass user input to parse_entities
  def gen_sub_topology(id, org_id, project, name, fact_table, entities_list, date_range_settings) do
    Multi.new()
    |> Multi.run(:update_to_db, fn _, _changes ->
      FactTables.update(fact_table, %{
        name: name,
        columns_metadata: entities_list,
        date_range_settings: date_range_settings
      })
    end)
    |> Multi.run(:gen_sub_topology, fn _, %{update_to_db: _fact_table} ->
      parse_entities(id, entities_list, org_id, project)
      {:ok, "You'll receive fact table data on channel"}
    end)
    |> run_under_transaction(:gen_sub_topology)
  end

  # NOTE: 1. parse_entities will seperate asset_type_list and sensor_type_list
  #       2. It'll create parent tree from the map stores in ETS table
  #       3. It'll pass the flow to validate_entities
  defp parse_entities(id, entities_list, org_id, project) do
    res =
      Enum.reduce(entities_list, {[], []}, fn entity, {acc1, acc2} ->
        acc1 = if entity["type"] == "AssetType", do: acc1 ++ [entity], else: acc1
        acc2 = if entity["type"] == "SensorType", do: acc2 ++ [entity], else: acc2
        {acc1, acc2}
      end)

    topology_map = gen_topology(org_id, project)
    parent_tree = NaryTree.from_map(topology_map)

    validate_entities(id, res, entities_list, parent_tree)
  end

  # NOTE: 1. execute_descendants will start a Genserver, which will do the asynchronous computation
  #          of subtree generation + subree validations + dynamic query building + fact table gen
  def execute_descendants(type, params) do
    FactTableServer.process({type, params})
  end

  # NOTE: this validate_entities will get executed if there is only one sensor_type is present in user input
  defp validate_entities(fact_table_id, {_, sensor_types}, entities_list, _)
       when length(sensor_types) == 1 and length(sensor_types) == length(entities_list) do
    execute_descendants("one_sensor_type", %{
      fact_table_id: fact_table_id,
      sensor_types: sensor_types
    })
  end

  # NOTE: this validate_entities will get executed if there is only one asset_type is present in user input
  defp validate_entities(fact_table_id, {asset_types, _}, entities_list, _)
       when length(asset_types) == 1 and length(asset_types) == length(entities_list) do
    execute_descendants("one_asset_type", %{
      fact_table_id: fact_table_id,
      asset_types: asset_types
    })
  end

  # NOTE: this validate_entities will get executed if there are multiple only sensor_types present in user input
  defp validate_entities(fact_table_id, {_, sensor_types}, entities_list, _)
       when length(sensor_types) == length(entities_list) do
    uniq_sensor_types = Enum.uniq_by(sensor_types, fn sensor_type -> sensor_type["id"] end)

    if length(uniq_sensor_types) == 1 do
      execute_descendants("sensor_params", %{
        fact_table_id: fact_table_id,
        entities_list: entities_list,
        uniq_sensor_types: uniq_sensor_types
      })
    else
      output =
        {:error, "Please attach parent asset_type as all the user-entities are of SensorTypes."}

      broadcast_to_channel(fact_table_id, output)
    end
  end

  # NOTE: this validate_entities will get executed if there are multiple only asset_types present in user input
  defp validate_entities(fact_table_id, {asset_types, _sensor_types}, entities_list, parent_tree)
       when length(asset_types) == length(entities_list) do
    uniq_asset_types = Enum.uniq_by(asset_types, fn asset_type -> asset_type["id"] end)

    if length(uniq_asset_types) == 1 do
      execute_descendants("asset_metadatas", %{
        fact_table_id: fact_table_id,
        uniq_asset_types: uniq_asset_types,
        asset_types: asset_types
      })
    else
      {entity_levels, {root_node, root_entity}, entity_map} =
        Enum.reduce(asset_types, {[], {nil, nil}, %{}}, fn entity, {acc1, {acc2, acc4}, acc3} ->
          node = NaryTree.get(parent_tree, "#{entity["id"]}_#{entity["name"]}")
          acc1 = acc1 ++ [node.level]

          {acc2, acc4} =
            if acc2 != nil && acc2.level < node.level, do: {acc2, acc4}, else: {node, entity}

          acc3 = Map.put_new(acc3, "#{entity["type"]}_#{entity["id"]}", false)
          {acc1, {acc2, acc4}, acc3}
        end)

      if length(Enum.uniq(entity_levels)) == 1 do
        output =
          {:error,
           "All the asset_type entities are at the same level, Please attach common parent entity."}

        broadcast_to_channel(fact_table_id, output)
      else
        node_tracker = Map.put(entity_map, "#{root_entity["type"]}_#{root_entity["id"]}", true)

        execute_descendants("hybrid", %{
          fact_table_id: fact_table_id,
          parent_tree: parent_tree,
          root_node: root_node,
          entities_list: entities_list,
          node_tracker: node_tracker
        })
      end
    end
  end

  # NOTE: 1. this validate_entities will find root elem of the user provided input with the help of subtree
  #       2. this'll then call the Genserver flow for further fact_table processing
  defp validate_entities(id, {asset_types, _sensor_types}, entities_list, parent_tree) do
    {_entity_levels, {root_node, root_entity}, entity_map} =
      Enum.reduce(asset_types, {[], {nil, nil}, %{}}, fn entity, {acc1, {acc2, acc4}, acc3} ->
        node = NaryTree.get(parent_tree, "#{entity["id"]}_#{entity["name"]}")
        acc1 = acc1 ++ [node.level]

        {acc2, acc4} =
          if acc2 != nil && acc2.level < node.level, do: {acc2, acc4}, else: {node, entity}

        acc3 = Map.put_new(acc3, "#{entity["type"]}_#{entity["id"]}", false)
        {acc1, {acc2, acc4}, acc3}
      end)

    node_tracker = Map.put(entity_map, "#{root_entity["type"]}_#{root_entity["id"]}", true)

    execute_descendants("hybrid", %{
      fact_table_id: id,
      parent_tree: parent_tree,
      root_node: root_node,
      entities_list: entities_list,
      node_tracker: node_tracker
    })
  end

  defp broadcast_to_channel(fact_table_id, output) do
    AcqdatApiWeb.Endpoint.broadcast("project_fact_table:#{fact_table_id}", "out_put_res", %{
      data: output
    })
  end

  defp ets_proj_key(project) do
    "#{project.id}_#{project.version}"
  end

  defp run_under_transaction(multi, _result_key) do
    multi
    |> Repo.transaction(timeout: :infinity)
    |> case do
      {:ok, result} ->
        {:ok, result[:del_rec_frm_fact_tab]}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
  end
end
