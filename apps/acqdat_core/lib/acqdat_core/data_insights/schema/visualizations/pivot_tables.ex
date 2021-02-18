defmodule AcqdatCore.DataInsights.Schema.Visualizations.PivotTables do
  use AcqdatCore.Schema

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
  def data_prop_gen(visualization, _options \\ []) do
    data = visualization.data_settings

    {:ok, "todo"}
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
