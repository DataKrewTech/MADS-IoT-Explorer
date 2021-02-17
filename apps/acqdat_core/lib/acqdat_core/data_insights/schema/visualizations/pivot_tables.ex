defmodule AcqdatCore.DataInsights.Schema.Visualizations.PivotTables do
  use AcqdatCore.Schema
  @behaviour AcqdatCore.DataInsights.Schema.Visualizations
  @visualization_type "Pivot Table"
  @visualization_name "Pivot Table"

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
    %{}
  end

  @impl true
  def data_settings() do
    %{}
  end
end
