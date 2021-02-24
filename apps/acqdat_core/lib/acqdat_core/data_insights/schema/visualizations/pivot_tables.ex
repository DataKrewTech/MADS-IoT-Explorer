defmodule AcqdatCore.DataInsights.Schema.Visualizations.PivotTables do
  use AcqdatCore.Schema
  alias AcqdatApi.DataInsights.Visualizations

  @behaviour AcqdatCore.DataInsights.Schema.Visualizations
  @visualization_type "Pivot Table"
  @visualization_name "Pivot Table"

  defstruct data_settings: %{
              filters: [%{}],
              columns: [%{}],
              rows: [%{}],
              values: [%{}]
            },
            visual_settings: %{}

  @impl true
  def visual_prop_gen(visualization, _options \\ []) do
    data = visualization.visual_settings

    {:ok, data}
  end

  @impl true
  def data_prop_gen(
        %{
          data_settings: %{
            "rows" => rows,
            "values" => values,
            "columns" => columns,
            "filters" => filters
          },
          fact_table_id: fact_tables_id
        },
        _options \\ []
      ) do
    fact_table_name = "fact_table_#{fact_tables_id}"

    try do
      query =
        if columns == [] do
          pivot_with_cube(fact_table_name, rows, values, filters)
        else
          pivot_with_crosstab(fact_table_name, rows, columns, values, filters)
        end

      pivot_output = Ecto.Adapters.SQL.query!(Repo, query, [], timeout: :infinity)

      {:ok,
       %{
         headers: pivot_output.columns,
         data: pivot_output.rows
       }}
    rescue
      error in Postgrex.Error ->
        {:error, error.postgres.message}
    end
  end

  @impl true
  def visualization_type() do
    @visualization_type
  end

  @impl true
  def visualization_name() do
    @visualization_name
  end

  @impl true
  def visual_settings() do
    Map.from_struct(__MODULE__).visual_settings
  end

  @impl true
  def data_settings() do
    Map.from_struct(__MODULE__).data_settings
  end

  def pivot_with_cube(fact_table_name, rows, values, filters) do
    rows_data = Enum.map(rows, fn x -> x["name"] end)

    # "Apartment" <> '' and "Building" <> ''
    rows_data_empty_chc_cond =
      Enum.reduce(rows_data, "", fn row, acc ->
        # acc <> "\"#{row}\"" <> "<>" <> '' <> "and "
        "#{acc} \"#{row}\" <> \'\' and "
      end)

    rows_data_empty_chc_cond =
      rows_data_empty_chc_cond |> String.slice(0..(String.length(rows_data_empty_chc_cond) - 6))

    rows_data = rows_data |> Enum.map_join(",", &"\"#{&1}\"")

    values_data = pivot_values_col_data(values, rows_data)
    [value | _] = values
    value_name = "\"#{value["name"]}\""

    if filters != [] do
      filter_data = pivot_filters_data_parsing(filters)

      """
        select * from
        (select #{values_data}
        from #{fact_table_name}
        where #{filter_data} and #{value_name} <> ''
        group by cube(#{rows_data})
        order by #{rows_data}) as pt where #{rows_data_empty_chc_cond}
      """
    else
      """
        select * from
        (select #{values_data}
        from #{fact_table_name}
        where #{value_name} <> ''
        group by cube(#{rows_data})
        order by #{rows_data}) as pt where #{rows_data_empty_chc_cond}
      """
    end
  end

  def pivot_with_crosstab(fact_table_name, rows, columns, values, filters) do
    [column | _] = columns
    column_name = "\"#{column["name"]}\""
    [value | _] = values

    filter_data1 = if filters != [], do: pivot_filters_data_parsing(filters), else: nil

    col_query =
      if column["action"] == "group" do
        if filter_data1 do
          """
            select
              time_bucket('#{column["group_interval"]} #{column["group_by"]}'::VARCHAR::INTERVAL, to_timestamp("#{
            column["name"]
          }", 'YYYY-MM-DD hh24:mi:ss'))
              from #{fact_table_name}
              where #{filter_data1}
              group by 1
              order by 1;
          """
        else
          """
            select
              time_bucket('#{column["group_interval"]} #{column["group_by"]}'::VARCHAR::INTERVAL, to_timestamp("#{
            column["name"]
          }", 'YYYY-MM-DD hh24:mi:ss'))
              from #{fact_table_name}
              group by 1
              order by 1;
          """
        end
      else
        if filter_data1 do
          "select distinct #{column_name} from #{fact_table_name} where #{column_name} is not null and length(#{
            column_name
          }) > 0 and #{filter_data1} order by 1"
        else
          "select distinct #{column_name} from #{fact_table_name} where #{column_name} is not null and length(#{
            column_name
          }) > 0 order by 1"
        end
      end

    column_res =
      Ecto.Adapters.SQL.query!(
        Repo,
        col_query,
        [],
        timeout: :infinity
      )

    columns_data =
      List.flatten(column_res.rows)
      |> Enum.filter(&(!is_nil(&1) && &1 != ""))
      |> Enum.uniq()
      |> Enum.map_join(",", &("\"#{&1}\"" <> " TEXT"))

    rows_data = Enum.map(rows, fn x -> x["name"] end)

    rows_data =
      if column["action"] == "group",
        do: rows_data |> Enum.join(","),
        else: rows_data |> Enum.map_join(",", &"\"#{&1}\"")

    columns_data = rows_data <> " TEXT," <> columns_data

    filter_data =
      if filters != [] do
        filter_data =
          Enum.reduce(filters, "", fn filter, acc ->
            # "Apartment" not in ('Apartment 2.2', 'Apartment 2.2')
            entities = filter["entities"] |> Enum.map_join(",", &"\'\'#{&1}\'\'")
            acc <> "\"#{filter["name"]}\" not in (#{entities}) and "
          end)

        String.slice(filter_data, 0..(String.length(filter_data) - 6))
      end

    crosstab_query =
      if column["action"] == "group" do
        inner_select_qry =
          aggregate_data_sub_query(
            value["action"],
            rows_data,
            column["name"],
            value,
            fact_table_name,
            column["group_interval"],
            column["group_by"],
            filter_data1
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
            column_name <> "," <> value_data_string(value)

        if filter_data do
          """
            SELECT *
            FROM crosstab('SELECT #{selected_data} FROM #{fact_table_name} where \"#{
            value["name"]
          }\" is not null and length(\"#{value["name"]}\") > 0 and #{filter_data}
            group by #{rows_data}, #{column_name} order by #{rows_data}, #{column_name}',
            'select distinct #{column_name} from #{fact_table_name} where #{column_name} is not null and length(#{
            column_name
          }) > 0 and #{filter_data} order by 1')
            AS final_result(#{columns_data})
          """
        else
          """
            SELECT *
            FROM crosstab('SELECT #{selected_data} FROM #{fact_table_name} where \"#{
            value["name"]
          }\" is not null and length(\"#{value["name"]}\") > 0
            group by #{rows_data}, #{column_name} order by #{rows_data}, #{column_name}',
            'select distinct #{column_name} from #{fact_table_name} where #{column_name} is not null and length(#{
            column_name
          }) > 0 order by 1')
            AS final_result(#{columns_data})
          """
        end
      end
  end

  defp aggregate_data_sub_query(
         action,
         rows_data,
         col_name,
         value,
         fact_table_name,
         group_int,
         group_by,
         filter_data1
       )
       when action == "count" do
    value_name = "\"#{value["name"]}\""

    if filter_data1 do
      """
        SELECT "#{rows_data}",
            time_bucket('#{group_int} #{group_by}'::VARCHAR::INTERVAL, to_timestamp("#{col_name}", 'YYYY-MM-DD hh24:mi:ss')) as "datetime_data",
            COUNT(#{value_name}) as \"#{value["title"]}\"
            FROM #{fact_table_name} where #{filter_data1} GROUP BY "#{rows_data}", "datetime_data" ORDER BY "#{
        rows_data
      }", "datetime_data"
      """
    else
      """
        SELECT "#{rows_data}",
            time_bucket('#{group_int} #{group_by}'::VARCHAR::INTERVAL, to_timestamp("#{col_name}", 'YYYY-MM-DD hh24:mi:ss')) as "datetime_data",
            COUNT(#{value_name}) as \"#{value["title"]}\"
            FROM #{fact_table_name} GROUP BY "#{rows_data}", "datetime_data" ORDER BY "#{
        rows_data
      }", "datetime_data"
      """
    end
  end

  defp aggregate_data_sub_query(
         action,
         rows_data,
         col_name,
         value,
         fact_table_name,
         group_int,
         group_by,
         filter_data1
       )
       when action == "avg" do
    value_name = "\"#{value["name"]}\""

    if filter_data1 do
      """
        SELECT "#{rows_data}",
            time_bucket('#{group_int} #{group_by}'::VARCHAR::INTERVAL, to_timestamp("#{col_name}", 'YYYY-MM-DD hh24:mi:ss')) as "datetime_data",
            ROUND(AVG(CAST(#{value_name} as NUMERIC)), 2) as \"#{value["title"]}\"
            FROM #{fact_table_name}
            where #{filter_data1} and #{value_name} is not null and length(#{value_name}) > 0
            GROUP BY "#{rows_data}", "datetime_data" ORDER BY "#{rows_data}", "datetime_data"
      """
    else
      """
        SELECT "#{rows_data}",
            time_bucket('#{group_int} #{group_by}'::VARCHAR::INTERVAL, to_timestamp("#{col_name}", 'YYYY-MM-DD hh24:mi:ss')) as "datetime_data",
            ROUND(AVG(CAST(#{value_name} as NUMERIC)), 2) as \"#{value["title"]}\"
            FROM #{fact_table_name}
            where #{value_name} is not null and length(#{value_name}) > 0
            GROUP BY "#{rows_data}", "datetime_data" ORDER BY "#{rows_data}", "datetime_data"
      """
    end
  end

  defp aggregate_data_sub_query(
         action,
         rows_data,
         col_name,
         value,
         fact_table_name,
         group_int,
         group_by,
         filter_data1
       )
       when action == "sum" do
    value_name = "\"#{value["name"]}\""

    if filter_data1 do
      """
        SELECT "#{rows_data}",
            time_bucket('#{group_int} #{group_by}'::VARCHAR::INTERVAL, to_timestamp("#{col_name}", 'YYYY-MM-DD hh24:mi:ss')) as "datetime_data",
            ROUND(SUM(CAST(#{value_name} as NUMERIC)), 2) as \"#{value["title"]}\"
            FROM #{fact_table_name}
            where #{filter_data1} and #{value_name} is not null and length(#{value_name}) > 0
            GROUP BY "#{rows_data}", "datetime_data" ORDER BY "#{rows_data}", "datetime_data"
      """
    else
      """
        SELECT "#{rows_data}",
            time_bucket('#{group_int} #{group_by}'::VARCHAR::INTERVAL, to_timestamp("#{col_name}", 'YYYY-MM-DD hh24:mi:ss')) as "datetime_data",
            ROUND(SUM(CAST(#{value_name} as NUMERIC)), 2) as \"#{value["title"]}\"
            FROM #{fact_table_name}
            where #{value_name} is not null and length(#{value_name}) > 0 
            GROUP BY "#{rows_data}", "datetime_data" ORDER BY "#{rows_data}", "datetime_data"
      """
    end
  end

  defp aggregate_data_sub_query(
         action,
         rows_data,
         col_name,
         value,
         fact_table_name,
         group_int,
         group_by,
         filter_data1
       )
       when action == "min" do
    value_name = "\"#{value["name"]}\""

    if filter_data1 do
      """
        SELECT "#{rows_data}",
            time_bucket('#{group_int} #{group_by}'::VARCHAR::INTERVAL, to_timestamp("#{col_name}", 'YYYY-MM-DD hh24:mi:ss')) as "datetime_data",
            ROUND(MIN(CAST(#{value_name} as NUMERIC)), 2) as \"#{value["title"]}\"
            FROM #{fact_table_name}
            where #{filter_data1} and #{value_name} is not null and length(#{value_name}) > 0
            GROUP BY "#{rows_data}", "datetime_data" ORDER BY "#{rows_data}", "datetime_data"
      """
    else
      """
        SELECT "#{rows_data}",
            time_bucket('#{group_int} #{group_by}'::VARCHAR::INTERVAL, to_timestamp("#{col_name}", 'YYYY-MM-DD hh24:mi:ss')) as "datetime_data",
            ROUND(MIN(CAST(#{value_name} as NUMERIC)), 2) as \"#{value["title"]}\"
            FROM #{fact_table_name}
            where #{value_name} is not null and length(#{value_name}) > 0
            GROUP BY "#{rows_data}", "datetime_data" ORDER BY "#{rows_data}", "datetime_data"
      """
    end
  end

  defp aggregate_data_sub_query(
         action,
         rows_data,
         col_name,
         value,
         fact_table_name,
         group_int,
         group_by,
         filter_data1
       )
       when action == "max" do
    value_name = "\"#{value["name"]}\""

    if filter_data1 do
      """
        SELECT "#{rows_data}",
            time_bucket('#{group_int} #{group_by}'::VARCHAR::INTERVAL, to_timestamp("#{col_name}", 'YYYY-MM-DD hh24:mi:ss')) as "datetime_data",
             ROUND(MAX(CAST(#{value_name} as NUMERIC)), 2) as \"#{value["title"]}\"
            FROM #{fact_table_name} 
            where #{filter_data1} and #{value_name} is not null and length(#{value_name}) > 0
            GROUP BY "#{rows_data}", "datetime_data" ORDER BY "#{rows_data}", "datetime_data"
      """
    else
      """
        SELECT "#{rows_data}",
            time_bucket('#{group_int} #{group_by}'::VARCHAR::INTERVAL, to_timestamp("#{col_name}", 'YYYY-MM-DD hh24:mi:ss')) as "datetime_data",
            ROUND(MAX(CAST(#{value_name} as NUMERIC)), 2) as \"#{value["title"]}\"
            FROM #{fact_table_name}
            where #{value_name} is not null and length(#{value_name}) > 0
            GROUP BY "#{rows_data}", "datetime_data" ORDER BY "#{rows_data}", "datetime_data"
      """
    end
  end

  defp pivot_values_col_data(values, rows_data) do
    Enum.reduce(values, rows_data, fn value, acc ->
      if Enum.member?(["sum", "avg", "min", "max"], value["action"]) do
        rows_data <>
          "," <>
          "ROUND(#{value["action"]}(CAST(\"#{value["name"]}\" AS NUMERIC)), 2) as \"#{
            value["title"]
          }\""
      else
        rows_data <>
          "," <> "#{value["action"]}(\"#{value["name"]}\") as \"#{value["title"]}\""
      end
    end)
  end

  defp pivot_filters_data_parsing(filters) do
    filter_data =
      Enum.reduce(filters, "", fn filter, acc ->
        # "Apartment" not in ('Apartment 2.2', 'Apartment 2.2')
        entities = filter["entities"] |> Enum.map_join(",", &"\'#{&1}\'")
        acc <> "\"#{filter["name"]}\" not in (#{entities}) and "
      end)

    filter_data = filter_data |> String.slice(0..(String.length(filter_data) - 6))
  end

  defp value_data_string(value) do
    if Enum.member?(["sum", "avg", "min", "max"], value["action"]) do
      "ROUND(#{value["action"]}(CAST(\"#{value["name"]}\" AS NUMERIC)), 2) as #{value["title"]}"
    else
      "#{value["action"]}(\"#{value["name"]}\") as #{value["title"]}"
    end
  end
end
