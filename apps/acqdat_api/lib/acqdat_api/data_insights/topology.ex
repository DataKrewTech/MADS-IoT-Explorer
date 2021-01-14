defmodule AcqdatApi.DataInsights.Topology do
  alias AcqdatCore.Model.EntityManagement.Project, as: ProjectModel
  alias AcqdatCore.Model.EntityManagement.SensorType, as: SensorTypeModel
  alias AcqdatCore.Model.EntityManagement.AssetType, as: AssetTypeModel
  alias AcqdatCore.Model.EntityManagement.Asset, as: AssetModel
  alias AcqdatApiWeb.DataInsights.TopologyEtsConfig
  alias AcqdatApi.DataInsights.FactTableGenWorker
  alias NaryTree
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Schema.EntityManagement.{Asset, Sensor}
  alias AcqdatCore.Domain.EntityManagement.SensorData
  alias AcqdatCore.Repo
  import Ecto.Query

  @table :proj_topology

  def entities(data) do
    sensor_types = SensorTypeModel.get_all(data)
    asset_types = AssetTypeModel.get_all(data)
    %{topology: %{sensor_types: sensor_types || [], asset_types: asset_types || []}}
  end

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

  def gen_sub_topology(id, org_id, project, entities_list) do
    parse_entities(id, entities_list, org_id, project)
  end

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

  defp validate_entities(_id, {_, sensor_types}, entities_list, _)
       when length(sensor_types) == 1 and length(sensor_types) == length(entities_list) do
    [%{"id" => id, "name" => name, "metadata_name" => metadata_name}] = sensor_types

    query =
      if metadata_name == "name" do
        from(sensor in Sensor,
          where: sensor.sensor_type_id == ^id,
          select: map(sensor, [:id, :name])
        )
      else
        [%{"date_from" => date_from, "date_to" => date_to}] = sensor_types

        sensor_ids =
          from(sensor in Sensor,
            where: sensor.sensor_type_id == ^id,
            select: sensor.id
          )
          |> Repo.all()

        date_from = from_unix(date_from)
        date_to = from_unix(date_to)

        query = SensorData.filter_by_date_query_wrt_parent(sensor_ids, date_from, date_to)
        SensorData.fetch_sensors_data(query, [metadata_name])
      end

    %{"#{name}" => Repo.all(query)}
  end

  defp validate_entities(_id, {asset_types, _}, entities_list, _)
       when length(asset_types) == 1 and length(asset_types) == length(entities_list) do
    [%{"id" => id, "name" => name, "metadata_name" => metadata_name}] = asset_types

    query =
      if metadata_name == "name" do
        from(asset in Asset,
          where: asset.asset_type_id == ^id,
          select: map(asset, [:id, :name])
        )
      else
        from(asset in Asset,
          where: asset.asset_type_id == ^id,
          cross_join: c in fragment("unnest(?)", asset.metadata),
          where: fragment("?->>'name'", c) in ^[metadata_name],
          select: %{
            id: asset.id,
            name: asset.name,
            value: fragment("(?->>'value', ?->>'name')", c, c)
          }
        )
      end

    %{"#{name}" => Repo.all(query)}
  end

  # TODO: Add proper error msg
  defp validate_entities(_id, {_, sensor_types}, entities_list, _)
       when length(sensor_types) == length(entities_list) do
    {:error, "Please attach parent asset_type as all the user-entities are of SensorTypes."}
  end

  # TODO: Need to refactor this piece of code and add proper error msg
  defp validate_entities(id, {asset_types, _sensor_types}, entities_list, parent_tree)
       when length(asset_types) == length(entities_list) do
    {entity_levels, {root_node, root_entity}, entity_map} =
      Enum.reduce(asset_types, {[], {nil, nil}, %{}}, fn entity, {acc1, {acc2, acc4}, acc3} ->
        node = NaryTree.get(parent_tree, "#{entity["id"]}")
        acc1 = acc1 ++ [node.level]

        {acc2, acc4} =
          if acc2 != nil && acc2.level < node.level, do: {acc2, acc4}, else: {node, entity}

        acc3 = Map.put_new(acc3, "#{entity["type"]}_#{entity["id"]}", false)
        {acc1, {acc2, acc4}, acc3}
      end)

    if length(Enum.uniq(entity_levels)) == 1 do
      {:error,
       "All the asset_type entities are at the same level, Please attach common parent entity."}
    else
      node_tracker = Map.put(entity_map, "#{root_entity["type"]}_#{root_entity["id"]}", true)

      execute_descendants(id, parent_tree, root_node, entities_list, node_tracker)
    end
  end

  defp validate_entities(id, {asset_types, sensor_types}, entities_list, parent_tree) do
    {entity_levels, {root_node, root_entity}, entity_map} =
      Enum.reduce(asset_types, {[], {nil, nil}, %{}}, fn entity, {acc1, {acc2, acc4}, acc3} ->
        node = NaryTree.get(parent_tree, "#{entity["id"]}")
        acc1 = acc1 ++ [node.level]

        {acc2, acc4} =
          if acc2 != nil && acc2.level < node.level, do: {acc2, acc4}, else: {node, entity}

        acc3 = Map.put_new(acc3, "#{entity["type"]}_#{entity["id"]}", false)
        {acc1, {acc2, acc4}, acc3}
      end)

    node_tracker = Map.put(entity_map, "#{root_entity["type"]}_#{root_entity["id"]}", true)

    execute_descendants(id, parent_tree, root_node, entities_list, node_tracker)
  end

  def execute_descendants(id, parent_tree, root_node, entities_list, node_tracker) do
    FactTableGenWorker.process({id, parent_tree, root_node, entities_list, node_tracker})
  end

  defp ets_proj_key(project) do
    "#{project.id}_#{project.version}"
  end

  defp from_unix(datetime) do
    {datetime, _} = Integer.parse(datetime)
    {:ok, res} = datetime |> DateTime.from_unix(:millisecond)
    res
  end
end
