defmodule AcqdatApiWeb.DataInsights.Topology do
  alias AcqdatCore.Model.EntityManagement.Project, as: ProjectModel
  alias AcqdatCore.Model.EntityManagement.SensorType, as: SensorTypeModel
  alias AcqdatCore.Model.EntityManagement.AssetType, as: AssetTypeModel
  alias AcqdatApiWeb.DataInsights.TopologyEtsConfig
  alias NaryTree
  alias NaryTree.Node
  import AcqdatApiWeb.Helpers

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
        acc1 = if entity[:type] == "AssetType", do: acc1 ++ [entity], else: acc1
        acc2 = if entity[:type] == "SensorType", do: acc2 ++ [entity], else: acc2
        {acc1, acc2}
      end)

    topology_map = gen_topology(org_id, project)
    parent_tree = NaryTree.from_map(topology_map)

    validate_entities(res, entities_list, parent_tree)
  end

  defp validate_entities({_, sensor_types}, _, _) when length(sensor_types) == 1 do
    IO.puts("implement query for single sensor_types details with timestamp column")
    [%{id: id, name: name}] = sensor_types
    subtree_map = %{id: id, name: name, type: "SensorType"}
  end

  defp validate_entities({asset_types, _}, _, _) when length(asset_types) == 1 do
    [%{id: id, name: name}] = asset_types
    subtree_map = %{id: id, name: name, type: "AssetType"}
  end

  # TODO: Add proper error msg
  defp validate_entities({_, sensor_types}, entities_list, _)
       when length(sensor_types) == length(entities_list) do
    IO.puts("Please attach parent entity as all the entities are of SensorTypes")
  end

  # TODO: Need to refactor this piece of code and add proper error msg
  def validate_entities1({asset_types, _sensor_types}, entities_list, parent_tree) do
    # when length(asset_types) == length(entities_list) do
    {entity_levels, {root_node, root_entity}, entity_map} =
      Enum.reduce(asset_types, {[], {nil, nil}, %{}}, fn entity, {acc1, {acc2, acc4}, acc3} ->
        node = NaryTree.get(parent_tree, entity.id)
        acc1 = acc1 ++ [node.level]

        {acc2, acc4} =
          if acc2 != nil && acc2.level < node.level, do: {acc2, acc4}, else: {node, entity}

        acc3 = Map.put_new(acc3, "#{entity.type}_#{entity.id}", false)
        {acc1, {acc2, acc4}, acc3}
      end)

    if length(Enum.uniq(entity_levels)) == 1 do
      IO.puts(
        "All the asset_type entities are at the same level, Please attach common parent entity"
      )
    else
      node_tracker = Map.put(entity_map, "#{root_entity.type}_#{root_entity.id}", true)

      IO.inspect(root_node)

      IO.inspect(node_tracker)

      # entities_list = Enum.reject(entities_list, fn entity -> entity == root_entity end)

      # find descendents of root element and check whether remaining entites exist or not?
      fetch_descendants(parent_tree, root_node, entities_list, node_tracker)
    end
  end

  defp validate_entities({asset_types, sensor_types}, entities_list, parent_tree) do
    IO.puts("Need to find root element here")
  end

  def traverse(tree, tree_node, entities_list, node_tracker) do
    key = "#{tree_node.type}_#{tree_node.id}"

    data = Enum.find(entities_list, fn x -> x.id == tree_node.id && x.type == tree_node.type end)

    node_tracker =
      if data do
        node_tracker ++ [data]
      else
        node_tracker
      end

    subtree_map =
      if data,
        do: %{id: tree_node.id, name: tree_node.name, type: tree_node.type, children: []},
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
              items = acc1[:children] ++ [data]
              acc1 = acc1 |> Map.put(:children, List.flatten(items))
              acc2 = acc2 ++ data2

              IO.puts("node_tracker")
              IO.inspect(node_tracker)
              {acc1, acc2}
            else
              acc2 = acc2 ++ node_tracker
              {acc1, acc2}
            end
          end)
    end
  end

  def traverse(parent_tree, node, _, _) when is_nil(node),
    do: raise("Expecting %NaryTree.Node(), found nil.")

  def traverse(parent_tree, %Node{children: children} = node, entities_list, node_tracker)
      when children == [] do
    IO.puts("inside childeren [] cond")
  end

  def fetch_descendants(parent_tree, root_node, entities_list, node_tracker) do
    # subtree_map = %{id: root_node.id, name: root_node.name, type: root_node.type}
    # node_tracker

    {subtree, node_tracker} = traverse(parent_tree, root_node, entities_list, [])
    # m = :maps.filter fn _, v -> v == false end, node_tracker
    # res = Map.keys(m)
    res = Enum.sort(Enum.uniq(node_tracker)) == Enum.sort(entities_list)

    if Enum.sort(Enum.uniq(node_tracker)) == Enum.sort(entities_list) do
      IO.puts("final output")
      # subtree = Map.put_new(subtree_map, :children, subtree) 
      IO.inspect(subtree)
    else
      IO.puts("throws error: followings are not connected to the tree")
    end
  end

  defp ets_proj_key(project) do
    "#{project.id}_#{project.version}"
  end
end
