defmodule AcqdatCore.DataInsights.Schema.Visualizations.Lines do
  use AcqdatCore.Schema

  @behaviour AcqdatCore.DataInsights.Schema.Visualizations
  @visualization_type "Lines"
  @visualization_name "Lines"
  @icon_id "line-chart"

  defstruct data_settings: %{
              x_axes: [],
              y_axes: [],
              legends: [],
              filters: []
            },
            visual_settings: %{}

  @impl true
  def visual_prop_gen(visualization, _options \\ []) do
    data = visualization.visual_settings

    {:ok, "todo"}
  end

  @impl true
  def data_prop_gen(
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

      output = Ecto.Adapters.SQL.query!(Repo, query, [], timeout: :infinity)

      IO.inspect(output)

      rows = output.rows

      [x_axis | _] = x_axes

      [value | _] = y_axes

      data =
        if length(legends) > 0 and length(rows) > 0 do
          [head | _] = output.columns

          data =
            rows |> Enum.group_by(fn [legend | _] -> legend end, fn [_legend | data] -> data end)

          Enum.map(data, fn {key, value} -> %{name: "#{head} #{key}", data: value} end)
        else
          [%{name: "#{x_axis["title"]} vs #{value["title"]}", data: rows}]
        end

      {:ok,
       %{
         headers: output.columns,
         data: data
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
  def icon_id() do
    @icon_id
  end

  @impl true
  def visual_settings() do
    Map.from_struct(__MODULE__).visual_settings
  end

  @impl true
  def data_settings() do
    Map.from_struct(__MODULE__).data_settings
  end

  defp compute_and_gen_data(fact_table_name, x_axes, y_axes, legends, filters)
       when length(legends) > 0 do
    [x_axis | _] = x_axes
    x_axis_col = "\"#{x_axis["name"]}\""

    [value | _] = y_axes
    value_name = "\"#{value["name"]}\""

    [legend | _] = legends
    legend_name = "\"#{legend["name"]}\""

    grouped_params = "\"#{legend["name"]}\"" <> "," <> x_axis_col

    if x_axis["action"] == "group" do
      values_data = y_axes_data(y_axes)

      """
        select #{legend_name},
        EXTRACT(EPOCH FROM (time_bucket('#{x_axis["group_interval"]} #{x_axis["group_by"]}'::VARCHAR::INTERVAL,
        to_timestamp("#{x_axis["name"]}", 'YYYY-MM-DD hh24:mi:ss'))))*1000 as \"#{x_axis["title"]}\",
        #{values_data}
        from #{fact_table_name}
        where #{value_name} <> '' 
        group by 1, 2
        order by 1, 2
      """
    else
      values_data = axes_data(y_axes, x_axis_col, legend_name)

      """
        select #{values_data}
        from #{fact_table_name}
        where #{value_name} <> '' 
        group by #{grouped_params} 
        order by #{grouped_params}
      """
    end
  end

  defp compute_and_gen_data(fact_table_name, x_axes, y_axes, legends, filters) do
    [x_axis | _] = x_axes
    x_axis_col = "\"#{x_axis["name"]}\""

    [value | _] = y_axes
    value_name = "\"#{value["name"]}\""

    if x_axis["action"] == "group" do
      values_data = y_axes_data(y_axes)

      """
        select EXTRACT(EPOCH FROM (time_bucket('#{x_axis["group_interval"]} #{x_axis["group_by"]}'::VARCHAR::INTERVAL,
        to_timestamp("#{x_axis["name"]}", 'YYYY-MM-DD hh24:mi:ss'))))*1000 as \"#{x_axis["title"]}\",
        #{values_data}
        from #{fact_table_name}
        where #{value_name} <> '' 
        group by 1
        order by 1
      """
    else
      values_data = axes_data(y_axes, x_axis_col)

      """
        select #{values_data}
        from #{fact_table_name}
        where #{value_name} <> '' 
        group by #{x_axis_col} 
        order by #{x_axis_col}
      """
    end
  end

  defp y_axes_data(y_axes) do
    Enum.reduce(y_axes, "", fn value, acc ->
      if Enum.member?(["sum", "avg", "min", "max"], value["action"]) do
        "ROUND(#{value["action"]}(CAST(\"#{value["name"]}\" AS NUMERIC)), 2) as \"#{
          value["title"]
        }\""
      else
        "#{value["action"]}(distinct(\"#{value["name"]}\")) as \"#{value["title"]}\""
      end
    end)
  end

  defp axes_data(y_axes, x_axes) do
    Enum.reduce(y_axes, x_axes, fn value, acc ->
      if Enum.member?(["sum", "avg", "min", "max"], value["action"]) do
        x_axes <>
          "," <>
          "ROUND(#{value["action"]}(CAST(\"#{value["name"]}\" AS NUMERIC)), 2) as \"#{
            value["title"]
          }\""
      else
        x_axes <>
          "," <> "#{value["action"]}(distinct(\"#{value["name"]}\")) as \"#{value["title"]}\""
      end
    end)
  end

  defp axes_data(y_axes, x_axes, legend) do
    Enum.reduce(y_axes, x_axes, fn value, acc ->
      if Enum.member?(["sum", "avg", "min", "max"], value["action"]) do
        legend <>
          "," <>
          x_axes <>
          "," <>
          "ROUND(#{value["action"]}(CAST(\"#{value["name"]}\" AS NUMERIC)), 2) as \"#{
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
