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

    {:ok, "todo"}
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
          Visualizations.pivot_with_cube(fact_table_name, rows, values, filters)
        else
          Visualizations.pivot_with_crosstab(fact_table_name, rows, columns, values, filters)
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
end
