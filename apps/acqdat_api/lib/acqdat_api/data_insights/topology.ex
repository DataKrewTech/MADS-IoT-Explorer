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
  alias Ecto.Multi
  alias AcqdatCore.Model.DataInsights.PivotTables, as: PivotTableModel
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

      # find descendents of root element and check whether remaining entites exist or not?
      # fetch_descendants(parent_tree, root_node, entities_list, node_tracker)
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

    # find descendents of root element and check whether remaining entites exist or not?
    # fetch_descendants(parent_tree, root_node, entities_list, node_tracker)

    execute_descendants(id, parent_tree, root_node, entities_list, node_tracker)
  end

  def execute_descendants(id, parent_tree, root_node, entities_list, node_tracker) do
    FactTableGenWorker.process({id, parent_tree, root_node, entities_list, node_tracker})
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

  def fetch_descendants(fact_table_id, parent_tree, root_node, entities_list, node_tracker) do
    {subtree, node_tracker} = traverse(parent_tree, root_node, entities_list, [])
    # IO.puts("----------------------------------------------------------------------")
    if Enum.sort(Enum.uniq(node_tracker)) == Enum.sort(entities_list) do
      IO.puts("final output")
      # subtree = Map.put_new(subtree_map, :children, subtree) 
      IO.inspect(subtree)
      subtree = NaryTree.from_map(subtree)
      dynamic_query(fact_table_id, subtree, entities_list)
    else
      {:error, "All entities are not directly connected, please connect common parent entity."}
    end
  end

  def dynamic_query(fact_table_id, subtree, user_list) do
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

    res = reduce_data(subtree, node, data, user_list)
    output = Map.merge(%{"#{node.id}" => data}, res)

    fact_table_name = "fact_table_#{fact_table_id}"

    fact_table_representation(fact_table_name, output, subtree)
  end

  def fact_table_representation(fact_table_name, output, subtree) do
    headers = output |> parse_table_headers_map()

    IO.puts("headers")
    IO.inspect(headers)
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

        computed_row =
          List.replace_at(
            empty_row,
            headers[subtree.root],
            parent_entity[:name] || parent_entity[:value]
          )

        computed_row =
          if parent_entity[:time] do
            List.replace_at(empty_row, headers[subtree.root] + 1, parent_entity[:time])
          else
            computed_row
          end

        computed_row =
          List.replace_at(
            computed_row,
            headers[child_entity],
            entity[:name] || entity[:value]
          )

        computed_row =
          if entity[:time] do
            List.replace_at(computed_row, headers[child_entity] + 1, entity[:time])
          else
            computed_row
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
        if node.type == "SensorType" and node.content != ["name"],
          do: size + length(node.content) * 2,
          else: size + length(node.content)
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
                  else: sum ++ ["#{node.name}_#{ele}", "#{node.name}_dateTime"]
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

    Ecto.Adapters.SQL.query!(Repo, qry, [])
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

  def gen_pivot_table(%{
        "org_id" => org_id,
        "project_id" => project_id,
        "fact_tables_id" => fact_tables_id,
        "name" => name,
        "user_list" => user_list
      }) do
    Multi.new()
    |> Multi.run(:persist_to_db, fn _, _changes ->
      PivotTableModel.create(%{
        org_id: org_id,
        project_id: project_id,
        fact_table_id: fact_tables_id,
        name: name,
        columns: user_list["columns"],
        rows: user_list["rows"],
        values: user_list["values"],
        filters: user_list["filters"]
      })
    end)
    |> Multi.run(:gen_pivot_data, fn _, %{persist_to_db: pivot_table} ->
      gen_pivot_data(pivot_table, fact_tables_id, user_list)
    end)
    |> run_under_transaction(:gen_pivot_data)
  end

  def gen_pivot_data(pivot_table, fact_tables_id, user_list) do
    fact_table_name = "fact_table_#{fact_tables_id}"

    query =
      if user_list["columns"] == [] do
        rows_data = Enum.map(user_list["rows"], fn x -> x["name"] end)
        rows_data = rows_data |> Enum.map_join(",", &"\"#{&1}\"")

        values_data =
          Enum.reduce(user_list["values"], rows_data, fn value, acc ->
            rows_data =
              if Enum.member?(["sum", "avg", "min", "max"], value["action"]) do
                rows_data <>
                  "," <>
                  "#{value["action"]}(CAST(\"#{value["name"]}\" AS NUMERIC)) as #{value["title"]}"
              else
                rows_data <>
                  "," <> "#{value["action"]}(\"#{value["name"]}\") as #{value["title"]}"
              end
          end)

        """
          select #{values_data}
          from #{fact_table_name}
          group by cube(#{rows_data})
          order by #{rows_data}
        """
      else
        [column | _] = user_list["columns"]
        [value | _] = user_list["values"]

        col_query =
          if column["action"] == "group" do
            """
              select
                date_trunc('day', to_timestamp("#{column["name"]}", 'YYYY-MM-DD'))
                from #{fact_table_name}
                group by 1
                order by 1;
            """
          else
            "select distinct #{column} from #{fact_table_name} where #{column} is not null order by 1"
          end

        column_res =
          Ecto.Adapters.SQL.query!(
            Repo,
            col_query,
            []
          )

        columns_data =
          List.flatten(column_res.rows)
          |> Enum.filter(&(!is_nil(&1)))
          |> Enum.uniq()
          |> Enum.map_join(",", &("\"#{&1}\"" <> " TEXT"))

        rows_data = Enum.map(user_list["rows"], fn x -> x["name"] end)
        rows_data = rows_data |> Enum.join(",")

        columns_data = rows_data <> " TEXT," <> columns_data

        crosstab_query =
          if column["action"] == "group" do
            # value_name = "\"#{value["name"]}\""

            inner_select_qry =
              aggregate_data_sub_query(
                value["action"],
                rows_data,
                column["name"],
                value,
                fact_table_name
              )

            """
              SELECT * FROM CROSSTAB ($$
                #{inner_select_qry}
              $$,$$
               #{col_query}
              $$
            ) AS (
                #{columns_data}
            )
            """
          else
            selected_data =
              rows_data <>
                "," <>
                column <> "," <> "#{value["action"]}(#{value["name"]}) as #{value["title"]}"

            """
              SELECT *
              FROM crosstab('SELECT #{selected_data} FROM #{fact_table_name} group by #{rows_data}, #{
              column
            } order by #{rows_data}, #{column}',
              'select distinct #{column} from #{fact_table_name} where #{column} is not null order by 1')
              AS final_result(#{columns_data})
            """
          end
      end

    res1 = Ecto.Adapters.SQL.query!(Repo, query, [])

    IO.inspect(res1)

    {:ok, %{headers: res1.columns, data: res1.rows, id: pivot_table.id, name: pivot_table.name}}
  end

  def aggregate_data_sub_query(action, rows_data, col_name, value, fact_table_name)
      when action == "count" do
    value_name = "\"#{value["name"]}\""

    """
      SELECT "#{rows_data}",
          date_trunc('day', to_timestamp("#{col_name}", 'YYYY-MM-DD')) as "datetime_data",
          COUNT(#{value_name}) as #{value["title"]}
          FROM #{fact_table_name} GROUP BY "#{rows_data}", "datetime_data" ORDER BY "#{rows_data}", "datetime_data"
    """
  end

  def aggregate_data_sub_query(action, rows_data, col_name, value, fact_table_name)
      when action == "sum" do
    value_name = "\"#{value["name"]}\""

    """
      SELECT "#{rows_data}",
          date_trunc('day', to_timestamp("#{col_name}", 'YYYY-MM-DD')) as "datetime_data",
          SUM(CAST(#{value_name} as NUMERIC)) as #{value["title"]}
          FROM #{fact_table_name} GROUP BY "#{rows_data}", "datetime_data" ORDER BY "#{rows_data}", "datetime_data"
    """
  end

  def aggregate_data_sub_query(action, rows_data, col_name, value, fact_table_name)
      when action == "min" do
    value_name = "\"#{value["name"]}\""

    """
      SELECT "#{rows_data}",
          date_trunc('day', to_timestamp("#{col_name}", 'YYYY-MM-DD')) as "datetime_data",
          MIN(CAST(#{value_name} as NUMERIC)) as #{value["title"]}
          FROM #{fact_table_name} GROUP BY "#{rows_data}", "datetime_data" ORDER BY "#{rows_data}", "datetime_data"
    """
  end

  def aggregate_data_sub_query(action, rows_data, col_name, value, fact_table_name)
      when action == "max" do
    value_name = "\"#{value["name"]}\""

    """
      SELECT "#{rows_data}",
          date_trunc('day', to_timestamp("#{col_name}", 'YYYY-MM-DD')) as "datetime_data",
          MAX(CAST(#{value_name} as NUMERIC)) as #{value["title"]}
          FROM #{fact_table_name} GROUP BY "#{rows_data}", "datetime_data" ORDER BY "#{rows_data}", "datetime_data"
    """
  end

  def fetch_paginated_fact_table(fact_table_name, page_number, page_size) do
    offset = page_size * (page_number - 1)

    data =
      Ecto.Adapters.SQL.query!(
        Repo,
        "select * from #{fact_table_name} OFFSET #{offset} LIMIT 20",
        []
      )

    %{headers: data.columns, data: data.rows, total: total_no_of_rec(fact_table_name)}
  end

  def reduce_data(subtree, tree_node, entities, user_list) do
    Enum.reduce(tree_node.children, %{}, fn id, acc ->
      node = NaryTree.get(subtree, id)

      # [_, id] = String.split(child_id, "_")

      # IO.puts("bfore processing")
      # IO.inspect(entities)

      entities = Enum.map(entities, fn entity -> entity[:id] end)

      # IO.puts("aftre processing")
      # IO.inspect(entities)

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
                  "metadata_name" => metadata_name,
                  "date_to" => date_to,
                  "date_from" => date_from
                }
              ] = sensor_entity

              date_from = from_unix(date_from)
              date_to = from_unix(date_to)

              query = SensorData.filter_by_date_query_wrt_parent(sensor_ids, date_from, date_to)
              SensorData.fetch_sensors_data(query, [metadata_name])
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
      res1 = reduce_data(subtree, node, k, user_list)
      res2 = Map.put_new(acc, node.id, k)
      # IO.puts("res1")
      # IO.inspect(res1)
      # IO.puts("res2")
      # IO.inspect(res2)

      # Map.merge(res2, res1, fn _k, v1, v2 -> Map.merge(v1, v2) end)
      Map.merge(res2, res1)
    end)
  end

  defp run_under_transaction(multi, result_key) do
    multi
    |> Repo.transaction()
    |> case do
      {:ok, result} ->
        {:ok, result}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
  end

  defp total_no_of_rec(fact_table_name) do
    res = Ecto.Adapters.SQL.query!(Repo, "select count(*) from #{fact_table_name}", [])
    res.rows |> List.first() |> List.first()
  end

  defp ets_proj_key(project) do
    "#{project.id}_#{project.version}"
  end

  defp from_unix(datetime) do
    {:ok, res} = datetime |> DateTime.from_unix(:millisecond)
    res
  end
end