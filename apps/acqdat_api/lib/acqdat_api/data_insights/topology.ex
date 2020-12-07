defmodule AcqdatApiWeb.DataInsights.Topology do
  alias AcqdatCore.Model.EntityManagement.Project, as: ProjectModel
  alias AcqdatCore.Model.EntityManagement.SensorType, as: SensorTypeModel
  alias AcqdatCore.Model.EntityManagement.AssetType, as: AssetTypeModel
  alias AcqdatCore.Model.EntityManagement.Asset, as: AssetModel
  alias AcqdatApiWeb.DataInsights.TopologyEtsConfig
  alias NaryTree
  alias NaryTree.Node
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Schema.EntityManagement.{Asset, Sensor}
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

  def gen_sub_topology(org_id, project, entities_list) do
    parse_entities(entities_list, org_id, project)
  end

  defp parse_entities(entities_list, org_id, project) do
    res =
      Enum.reduce(entities_list, {[], []}, fn entity, {acc1, acc2} ->
        acc1 = if entity["type"] == "AssetType", do: acc1 ++ [entity], else: acc1
        acc2 = if entity["type"] == "SensorType", do: acc2 ++ [entity], else: acc2
        {acc1, acc2}
      end)

    topology_map = gen_topology(org_id, project)
    parent_tree = NaryTree.from_map(topology_map)

    validate_entities(res, entities_list, parent_tree)
  end

  defp validate_entities({_, sensor_types}, entities_list, _)
       when length(sensor_types) == 1 and length(sensor_types) == length(entities_list) do
    IO.puts("implement query for single sensor_types details with timestamp column")
    [%{"id" => id, "name" => name}] = sensor_types
    subtree_map = %{id: id, name: name, type: "SensorType"}
  end

  defp validate_entities({asset_types, _}, entities_list, _)
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
  defp validate_entities({_, sensor_types}, entities_list, _)
       when length(sensor_types) == length(entities_list) do
    {:error, "Please attach parent asset_type as all the user-entities are of SensorTypes."}
  end

  # TODO: Need to refactor this piece of code and add proper error msg
  defp validate_entities({asset_types, _sensor_types}, entities_list, parent_tree)
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

      IO.inspect(root_node)

      IO.inspect(node_tracker)

      # entities_list = Enum.reject(entities_list, fn entity -> entity == root_entity end)

      # find descendents of root element and check whether remaining entites exist or not?
      fetch_descendants(parent_tree, root_node, entities_list, node_tracker)
    end
  end

  defp validate_entities({asset_types, sensor_types}, entities_list, parent_tree) do
    {entity_levels, {root_node, root_entity}, entity_map} =
      Enum.reduce(asset_types, {[], {nil, nil}, %{}}, fn entity, {acc1, {acc2, acc4}, acc3} ->
        node = NaryTree.get(parent_tree, "#{entity["id"]}")
        acc1 = acc1 ++ [node.level]

        {acc2, acc4} =
          if acc2 != nil && acc2.level < node.level, do: {acc2, acc4}, else: {node, entity}

        acc3 = Map.put_new(acc3, "#{entity["type"]}_#{entity["id"]}", false)
        {acc1, {acc2, acc4}, acc3}
      end)

    # require IEx
    # IEx.pry

    node_tracker = Map.put(entity_map, "#{root_entity["type"]}_#{root_entity["id"]}", true)

    IO.inspect(root_node)

    IO.inspect(node_tracker)

    # entities_list = Enum.reject(entities_list, fn entity -> entity == root_entity end)

    # find descendents of root element and check whether remaining entites exist or not?
    fetch_descendants(parent_tree, root_node, entities_list, node_tracker)
  end

  def traverse(tree, tree_node, entities_list, node_tracker) do
    key = "#{tree_node.type}_#{tree_node.id}"

    {data, metadata} =
      Enum.reduce(entities_list, {[], []}, fn x, {acc1, acc2} ->
        if "#{x["id"]}" == tree_node.id && x["type"] == tree_node.type do
          {acc1 ++ [x], acc2 ++ [x["metadata_name"]]}
        else
          {acc1, acc2}
        end
      end)

    # data = Enum.find(entities_list, fn x -> "#{x.id}" == tree_node.id && x.type == tree_node.type end)

    node_tracker =
      if data && metadata != [] do
        node_tracker ++ data
      else
        node_tracker
      end

    subtree_map =
      if data != [],
        do: %{
          id: tree_node.id,
          name: tree_node.name,
          type: tree_node.type,
          content: metadata,
          children: []
        },
        else: []

    case tree_node.children do
      [] ->
        {subtree_map, node_tracker}

      _ ->
        res =
          Enum.reduce(tree_node.children, {subtree_map, node_tracker}, fn child_id,
                                                                          {acc1, acc2} ->
            node = NaryTree.get(tree, child_id)
            res = traverse(tree, node, entities_list, node_tracker)
            {data, data2} = res

            if res != nil && acc1 != %{} && acc1 != [] do
              IO.inspect(acc1)
              items = acc1[:children] ++ [data]
              acc1 = acc1 |> Map.put(:children, List.flatten(items))
              acc2 = acc2 ++ data2
              {acc1, acc2}
            else
              acc2 = acc2 ++ data2
              acc1 = acc1 ++ data
              {acc1, acc2}
            end
          end)
    end
  end

  def fetch_descendants(parent_tree, root_node, entities_list, node_tracker) do
    {subtree, node_tracker} = traverse(parent_tree, root_node, entities_list, [])
    # IO.puts("----------------------------------------------------------------------")
    if Enum.sort(Enum.uniq(node_tracker)) == Enum.sort(entities_list) do
      IO.puts("final output")
      # subtree = Map.put_new(subtree_map, :children, subtree) 
      IO.inspect(subtree)
      # require IEx
      # IEx.pry
      subtree = NaryTree.from_map(subtree)
      dynamic_query(subtree)
    else
      {:error, "All entities are not directly connected, please connect common parent entity."}
    end
  end

  def dynamic_query(subtree) do
    IO.inspect(subtree)
    node = NaryTree.get(subtree, subtree.root)

    # [_, id] = String.split(subtree.root, "_")
    # id = subtree.root
    data =
      from(asset in Asset,
        where: asset.asset_type_id == ^node.id,
        select: map(asset, [:id, :name])
      )
      |> Repo.all()

    res = reduce_data(subtree, node, data)
    Map.merge(%{"#{node.name}" => data}, res)
  end

  def reduce_data(subtree, tree_node, entities) do
    Enum.reduce(tree_node.children, %{}, fn id, acc ->
      node = NaryTree.get(subtree, id)

      # [_, id] = String.split(child_id, "_")

      # IO.puts("bfore processing")
      # IO.inspect(entities)

      entities = Enum.map(entities, fn entity -> entity[:id] end)

      # IO.puts("aftre processing")
      # IO.inspect(entities)

      query =
        if node.content != [] && node.content != :empty do
          content = node.content -- ["name"]

          if node.type == "AssetType" do
            from(asset in Asset,
              where: asset.asset_type_id == ^id and asset.parent_id in ^entities,
              cross_join: c in fragment("unnest(?)", asset.metadata),
              where: fragment("?->>'name'", c) in ^content,
              select: %{
                id: asset.id,
                name: asset.name,
                value: fragment("?->>'value'", c),
                param_name: fragment("?->>'name'", c)
              }
            )
          else
            from(sensor in Sensor,
              where:
                sensor.sensor_type_id == ^id and sensor.parent_id in ^entities and
                  sensor.parent_type == "Asset",
              select: map(sensor, [:id, :name])
            )
          end
        else
          if node.type == "AssetType" do
            from(asset in Asset,
              where: asset.asset_type_id == ^id and asset.parent_id in ^entities,
              select: map(asset, [:id, :name])
            )
          else
            from(sensor in Sensor,
              where:
                sensor.sensor_type_id == ^id and sensor.parent_id in ^entities and
                  sensor.parent_type == "Asset",
              select: map(sensor, [:id, :name])
            )
          end
        end

      # require IEx
      # IEx.pry

      k = Repo.all(query)

      k =
        if k == [] do
          assets = AssetModel.get_all_by_ids(entities)

          asset_ids =
            Enum.reduce(assets, [], fn asset, acc ->
              data = AssetModel.fetch_child_descendants(asset)

              res =
                if node.type == "AssetType" do
                  Enum.reduce(data, [], fn x, acc1 ->
                    if "#{x.asset_type_id}" == id,
                      do: acc1 ++ [%{parent_id: asset.id, name: x.name, id: x.id}],
                      else: acc1
                  end)
                else
                  list = Enum.map(data, fn x -> x.id end)

                  query =
                    from(sensor in Sensor,
                      where:
                        sensor.sensor_type_id == ^id and sensor.parent_id in ^list and
                          sensor.parent_type == "Asset",
                      select: map(sensor, [:id, :name])
                    )

                  output = Repo.all(query)
                  Enum.map(output, fn x -> Map.merge(%{parent_id: asset.id}, x) end)
                end

              acc ++ res
            end)
        else
          k
        end

      # IO.puts("-----------------------------")
      # IO.inspect(child_id)
      # IO.inspect(k)
      # IO.puts("-----------------------------")
      res1 = reduce_data(subtree, node, k)
      res2 = Map.put_new(acc, node.name, k)
      # IO.puts("res1")
      # IO.inspect(res1)
      # IO.puts("res2")
      # IO.inspect(res2)

      # Map.merge(res2, res1, fn _k, v1, v2 -> Map.merge(v1, v2) end)
      Map.merge(res2, res1)
    end)
  end

  defp ets_proj_key(project) do
    "#{project.id}_#{project.version}"
  end
end
