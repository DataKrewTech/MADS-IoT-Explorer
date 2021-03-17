defmodule AcqdatCore.DataInsights.Domain.DataGenerator do
  import AcqdatCore.DataInsights.Domain.DataFilter
  alias AcqdatCore.Repo

  def process_visual_data(options, type) do
    visual_settings = %{chart: %{type: type}, legend: %{enabled: true}}

    if options[:chart_category] && options[:chart_category] == "highchart",
      do: Map.put(visual_settings, :xAxis, %{type: "category"}),
      else: visual_settings
  end

  def process_data(
        %{
          data_settings: %{
            "x_axes" => x_axes,
            "y_axes" => y_axes,
            "legends" => legends,
            "filters" => filters
          },
          fact_table_id: fact_tables_id
        },
        _options \\ []
      ) do
    fact_table_name = "fact_table_#{fact_tables_id}"

    try do
      query = compute_and_gen_data(fact_table_name, x_axes, y_axes, legends, filters)

      [x_axis | _] = x_axes

      [value | _] = y_axes

      chart_category = if x_axis["action"] == "group", do: "stock_chart", else: "highchart"

      if length(y_axes) > 1 do
        {:ok,
         %{
           headers: [],
           data: query,
           chart_category: chart_category
         }}
      else
        output = Ecto.Adapters.SQL.query!(Repo, query, [], timeout: :infinity)

        rows = output.rows

        data =
          if length(legends) > 0 and length(rows) > 0 do
            [head | _] = output.columns

            data =
              rows
              |> Enum.group_by(fn [legend | _] -> legend end, fn [_legend | data] -> data end)

            Enum.map(data, fn {key, value} -> %{name: "#{head} #{key}", data: value} end)
          else
            [%{name: "#{x_axis["title"]} vs #{value["title"]}", data: rows}]
          end

        {:ok,
         %{
           headers: output.columns,
           data: data,
           chart_category: chart_category
         }}
      end
    rescue
      error in Postgrex.Error ->
        {:error, error.postgres.message}
    end
  end

  defp compute_and_gen_data(fact_table_name, x_axes, y_axes, _legends, filters)
       when length(y_axes) > 1 do
    [x_axis | _] = x_axes

    Enum.reduce(y_axes, [], fn y_axis, acc ->
      query = compute_and_gen_data(fact_table_name, x_axes, [y_axis], "", filters)

      output = Ecto.Adapters.SQL.query!(Repo, query, [], timeout: :infinity)
      acc ++ [%{name: "#{x_axis["title"]} vs #{y_axis["title"]}", data: output.rows}]
    end)
  end

  defp compute_and_gen_data(fact_table_name, x_axes, y_axes, legends, filters)
       when length(legends) > 0 do
    [x_axis | _] = x_axes
    x_axis_col = "\"#{x_axis["name"]}\""

    [legend | _] = legends
    legend_name = "\"#{legend["name"]}\""

    grouped_params = "\"#{legend["name"]}\"" <> "," <> x_axis_col

    if x_axis["action"] == "group" do
      values_data = y_axes_data(y_axes)

      """
        select #{legend_name},
        EXTRACT(EPOCH FROM (time_bucket('#{x_axis["group_interval"]} #{x_axis["group_by"]}'::VARCHAR::INTERVAL,
        to_timestamp(cast("#{x_axis["name"]}" as TEXT, 'YYYY-MM-DD hh24:mi:ss'))))*1000 as \"#{
        x_axis["title"]
      }\",
        #{values_data}
        from #{fact_table_name}
        #{filters_query(filters)}
        group by 1, 2
        order by 1, 2
      """
    else
      values_data = axes_data(y_axes, x_axis_col, legend_name)

      """
        select #{values_data}
        from #{fact_table_name}
        #{filters_query(filters)}
        group by #{grouped_params} 
        order by #{grouped_params}
      """
    end
  end

  defp compute_and_gen_data(fact_table_name, x_axes, y_axes, _legends, filters) do
    [x_axis | _] = x_axes
    x_axis_col = "\"#{x_axis["name"]}\""

    if x_axis["action"] == "group" do
      values_data = y_axes_data(y_axes)

      """
        select EXTRACT(EPOCH FROM (time_bucket('#{x_axis["group_interval"]} #{x_axis["group_by"]}'::VARCHAR::INTERVAL,
        to_timestamp(cast("#{x_axis["name"]}" as TEXT), 'YYYY-MM-DD hh24:mi:ss'))))*1000 as \"#{
        x_axis["title"]
      }\",
        #{values_data}
        from #{fact_table_name}
        #{filters_query(filters)}
        group by 1
        order by 1
      """
    else
      values_data = axes_data(y_axes, x_axis_col)

      """
        select #{values_data}
        from #{fact_table_name}
        #{filters_query(filters)}
        group by #{x_axis_col} 
        order by #{x_axis_col}
      """
    end
  end

  defp y_axes_data(y_axes) do
    Enum.reduce(y_axes, "", fn value, _acc ->
      if Enum.member?(["sum", "avg", "min", "max"], value["action"]) do
        "CAST(ROUND(#{value["action"]}(CAST(\"#{value["name"]}\" AS NUMERIC)), 2) AS FLOAT) as \"#{
          value["title"]
        }\""
      else
        "#{value["action"]}(distinct(\"#{value["name"]}\")) as \"#{value["title"]}\""
      end
    end)
  end

  defp axes_data(y_axes, x_axes) do
    Enum.reduce(y_axes, x_axes, fn value, _acc ->
      if Enum.member?(["sum", "avg", "min", "max"], value["action"]) do
        x_axes <>
          "," <>
          "CAST(ROUND(#{value["action"]}(CAST(\"#{value["name"]}\" AS NUMERIC)), 2) AS FLOAT) as \"#{
            value["title"]
          }\""
      else
        x_axes <>
          "," <> "#{value["action"]}(distinct(\"#{value["name"]}\")) as \"#{value["title"]}\""
      end
    end)
  end

  defp axes_data(y_axes, x_axes, legend) do
    Enum.reduce(y_axes, x_axes, fn value, _acc ->
      if Enum.member?(["sum", "avg", "min", "max"], value["action"]) do
        legend <>
          "," <>
          x_axes <>
          "," <>
          "CAST(ROUND(#{value["action"]}(CAST(\"#{value["name"]}\" AS NUMERIC)), 2) AS FLOAT) as \"#{
            value["title"]
          }\""
      else
        legend <>
          "," <>
          x_axes <>
          "," <> "#{value["action"]}(distinct(\"#{value["name"]}\")) as \"#{value["title"]}\""
      end
    end)
  end
end
