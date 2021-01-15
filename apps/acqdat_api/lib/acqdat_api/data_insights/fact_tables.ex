defmodule AcqdatApi.DataInsights.FactTables do
  import Ecto.Query
  alias AcqdatCore.Model.DataInsights.FactTables
  alias AcqdatCore.Model.EntityManagement.Asset, as: AssetModel
  alias AcqdatCore.Schema.EntityManagement.{Asset, Sensor}
  alias AcqdatCore.Domain.EntityManagement.SensorData
  alias AcqdatCore.Repo
  alias NaryTree

  def create(org_id, %{name: project_name, id: project_id}) do
    res_name = :crypto.strong_rand_bytes(5) |> Base.url_encode64() |> binary_part(0, 5)
    fact_table_name = "#{project_name}_fact_table_#{res_name}"

    FactTables.create(%{name: fact_table_name, org_id: org_id, project_id: project_id})
  end

  def fetch_name_by_id(%{"id" => id, "name" => name}) do
    fact_table_name = "fact_table_#{id}"

    qry = """
      select distinct "#{name}" from #{fact_table_name}
      where "#{name}" is not null and length("#{name}") > 0
      order by 1
    """

    res = Ecto.Adapters.SQL.query!(Repo, qry, [])
    %{data: List.flatten(res.rows)}
  end

  def fetch_descendants(fact_table_id, parent_tree, root_node, entities_list, node_tracker) do
    {subtree, node_tracker} = traverse_n_gen_subtree(parent_tree, root_node, entities_list, [])

    if Enum.sort(Enum.uniq(node_tracker)) == Enum.sort(entities_list) do
      subtree = NaryTree.from_map(subtree)
      build_dynamic_query(fact_table_id, subtree, entities_list)
    else
      {:error, "All entities are not directly connected, please connect common parent entity."}
    end
  end

  def build_dynamic_query(fact_table_id, subtree, user_list) do
    node = NaryTree.get(subtree, subtree.root)

    # [_, id] = String.split(subtree.root, "_")
    # id = subtree.root
    data =
      from(asset in Asset,
        where: asset.asset_type_id == ^node.id,
        select: map(asset, [:id, :name])
      )
      |> Repo.all()

    res = fetch_data_using_dynamic_query(subtree, node, data, user_list)
    output = Map.merge(%{"#{node.id}" => data}, res)

    fact_table_name = "fact_table_#{fact_table_id}"

    fact_table_representation(fact_table_name, output, subtree)
  end

  def fact_table_representation(fact_table_name, output, subtree) do
    headers = output |> parse_table_headers_map()
    tree_elem = output[subtree.root]

    rows_len = subtree |> compute_table_row_len()

    data =
      Enum.reduce(tree_elem, [], fn parent_entity, acc ->
        node = NaryTree.get(subtree, subtree.root)

        res =
          Enum.reduce(node.children, [], fn child_entity, acc1 ->
            acc1 ++
              compute_table_data(output, subtree, headers, rows_len, parent_entity, child_entity)
          end)

        acc ++ res
      end)

    table_headers = output |> gen_fact_table_headers(subtree)
    table_body = data |> convert_table_data_to_text

    create_fact_table_view(fact_table_name, table_headers, table_body)

    data = Ecto.Adapters.SQL.query!(Repo, "select * from #{fact_table_name} LIMIT 20", [])
    %{headers: data.columns, data: data.rows, total: total_no_of_rec(fact_table_name)}
  end

  def compute_table_data(output, subtree, headers, rows_len, parent_entity, child_entity) do
    Enum.reduce(output[child_entity], [], fn entity, acc3 ->
      if entity.parent_id == parent_entity.id do
        empty_row = List.duplicate(nil, rows_len)
        child_node = NaryTree.get(subtree, child_entity)

        indx =
          if headers[subtree.root] != 0 do
            ind = length(child_node.content -- ["name"]) * 2 + headers[subtree.root]
            # if Enum.member?(child_node.content, "name"), do: ind + 1, else: ind
            ind - 1
          else
            headers[subtree.root]
          end

        computed_row =
          List.replace_at(empty_row, indx, parent_entity[:name] || parent_entity[:value])

        computed_row =
          if parent_entity[:time] do
            List.replace_at(empty_row, indx + 1, parent_entity[:time])
          else
            computed_row
          end

        computed_row =
          if entity[:value] && entity[:param_name] do
            index_pos = headers[child_entity]
            index = Enum.find_index(child_node.content, fn x -> x == entity[:param_name] end)
            index_pos = if index == 0, do: index_pos + index, else: index_pos + index + 1

            computed_row =
              List.replace_at(
                computed_row,
                index_pos,
                entity[:value]
              )

            computed_row =
              List.replace_at(
                computed_row,
                index_pos + 1,
                entity[:time]
              )

            index = Enum.find_index(child_node.content, fn x -> x == "name" end)

            if index do
              index_pos = index_pos + index + 1

              computed_row =
                List.replace_at(
                  computed_row,
                  index_pos,
                  entity[:name]
                )
            else
              computed_row
            end
          else
            List.replace_at(
              computed_row,
              headers[child_entity],
              entity[:name]
            )
          end

        data = fetch_children(child_node, entity, subtree, output, computed_row, headers)

        if data != [], do: acc3 ++ data, else: acc3 ++ [computed_row]
      else
        acc3
      end
    end)
  end

  def compute_table_row_len(subtree) do
    Enum.reduce(subtree.nodes, 0, fn {key, node}, size ->
      if node.content != :empty do
        if node.type == "SensorType" and node.content != ["name"] do
          len = length(node.content -- ["name"]) * 2
          if Enum.member?(node.content, "name"), do: size + len + 1, else: size + len
        else
          size + length(node.content)
        end
      else
        size + 1
      end
    end)
  end

  def parse_table_headers_map(output) do
    Stream.with_index(Map.keys(output), 0)
    |> Enum.reduce(%{}, fn {v, k}, acc ->
      Map.put(acc, v, k)
    end)
  end

  def gen_fact_table_headers(output, subtree) do
    headers =
      Map.keys(output)
      |> Enum.reduce([], fn x, acc ->
        node = NaryTree.get(subtree, x)

        if node.content != ["name"] && node.content != :empty do
          res =
            if node.type == "SensorType" do
              Enum.reduce(node.content, [], fn ele, sum ->
                if ele == "name",
                  do: sum ++ ["#{node.name}_#{ele}"],
                  else: sum ++ ["#{node.name}_#{ele}", "#{node.name}_#{ele}_dateTime"]
              end)
            else
              Enum.map(node.content, fn z -> "#{node.name}_#{z}" end)
            end

          acc ++ res
        else
          acc ++ [node.name]
        end
      end)

    Enum.map_join(headers, ",", &"\"#{&1}\"")
  end

  def convert_table_data_to_text(data) do
    text_form =
      Enum.reduce(data, "", fn ele, acc ->
        acc <> "(" <> Enum.map_join(ele, ",", &"\'#{&1}\'") <> "),"
      end)

    {text_form, _} = String.split_at(text_form, -1)
    text_form
  end

  def create_fact_table_view(fact_table_name, table_headers, data) do
    Ecto.Adapters.SQL.query!(Repo, "drop view if exists #{fact_table_name};", [])

    qry = """
      CREATE OR REPLACE VIEW #{fact_table_name} AS
      SELECT * FROM(
      VALUES 
      #{data}) as #{fact_table_name}(#{table_headers});
    """

    Ecto.Adapters.SQL.query!(Repo, qry, [], timeout: :infinity)
  end

  def fetch_children(parent_node, parent_entity, subtree, output, computed_row, headers) do
    Enum.reduce(parent_node.children, [], fn child_entity, acc1 ->
      res1 =
        Enum.reduce(output[child_entity], [], fn entity, acc3 ->
          if entity.parent_id == parent_entity.id do
            computed_row =
              List.replace_at(
                computed_row,
                headers[child_entity],
                entity[:name] || entity[:value]
              )

            child_node = NaryTree.get(subtree, child_entity)
            data = fetch_children(child_node, entity, subtree, output, computed_row, headers)
            if data != [], do: acc3 ++ data, else: acc3 ++ [computed_row]
          else
            acc3
          end
        end)

      acc1 ++ res1
    end)
  end

  def fetch_paginated_fact_table(fact_table_name, page_number, page_size) do
    offset = page_size * (page_number - 1)

    data =
      Ecto.Adapters.SQL.query!(
        Repo,
        "select * from #{fact_table_name} OFFSET #{offset} LIMIT 20",
        [],
        timeout: :infinity
      )

    %{headers: data.columns, data: data.rows, total: total_no_of_rec(fact_table_name)}
  end

  def fetch_data_using_dynamic_query(subtree, tree_node, entities, user_list) do
    Enum.reduce(tree_node.children, %{}, fn id, acc ->
      node = NaryTree.get(subtree, id)
      entities = Enum.map(entities, fn entity -> entity[:id] end)

      query =
        if node.content != [] && node.content != :empty && node.content != ["name"] do
          content = node.content -- ["name"]

          if node.type == "AssetType" do
            from(asset in Asset,
              where: asset.asset_type_id == ^id and asset.parent_id in ^entities,
              cross_join: c in fragment("unnest(?)", asset.metadata),
              where: fragment("?->>'name'", c) in ^content,
              select: %{
                id: asset.id,
                name: asset.name,
                parent_id: asset.parent_id,
                value: fragment("?->>'value'", c),
                param_name: fragment("?->>'name'", c)
              }
            )
          else
            subquery =
              from(sensor in Sensor,
                where:
                  sensor.sensor_type_id == ^id and sensor.parent_id in ^entities and
                    sensor.parent_type == "Asset",
                select: sensor.id
              )

            sensor_ids = Repo.all(subquery)

            if sensor_ids != [] do
              sensor_entity =
                Enum.filter(user_list, fn x ->
                  "#{x["id"]}" == node.id && x["type"] == node.type
                end)

              [
                %{
                  "metadata_name" => _metadata_name,
                  "date_to" => date_to,
                  "date_from" => date_from
                }
                | _
              ] = sensor_entity

              parameters = Enum.map(sensor_entity, fn entity -> entity["metadata_name"] end)

              date_from = from_unix(date_from)
              date_to = from_unix(date_to)

              query = SensorData.filter_by_date_query_wrt_parent(sensor_ids, date_from, date_to)
              SensorData.fetch_sensors_data(query, parameters)
            else
              subquery
            end
          end
        else
          if node.type == "AssetType" do
            from(asset in Asset,
              where: asset.asset_type_id == ^id and asset.parent_id in ^entities,
              select: map(asset, [:id, :name, :parent_id])
            )
          else
            from(sensor in Sensor,
              where:
                sensor.sensor_type_id == ^id and sensor.parent_id in ^entities and
                  sensor.parent_type == "Asset",
              select: map(sensor, [:id, :name, :parent_id])
            )
          end
        end

      entity_data = Repo.all(query)

      entity_data =
        if entity_data == [] do
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
          entity_data
        end

      res1 = fetch_data_using_dynamic_query(subtree, node, entity_data, user_list)
      res2 = Map.put_new(acc, node.id, entity_data)
      Map.merge(res2, res1)
    end)
  end

  defp traverse_n_gen_subtree(tree, tree_node, entities_list, node_tracker) do
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
            res = traverse_n_gen_subtree(tree, node, entities_list, node_tracker)
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

  defp total_no_of_rec(fact_table_name) do
    res =
      Ecto.Adapters.SQL.query!(Repo, "select count(*) from #{fact_table_name}", [],
        timeout: :infinity
      )

    res.rows |> List.first() |> List.first()
  end

  defp from_unix(datetime) do
    {datetime, _} = Integer.parse(datetime)
    {:ok, res} = datetime |> DateTime.from_unix(:millisecond)
    res
  end
end
