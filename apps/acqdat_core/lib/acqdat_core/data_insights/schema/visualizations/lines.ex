defmodule AcqdatCore.DataInsights.Schema.Visualizations.Lines do
  use AcqdatCore.Schema
  alias AcqdatCore.DataInsights.Domain.DataGenerator

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
  def visual_prop_gen(_visualization, options \\ %{}) do
    DataGenerator.process_visual_data(options, "line")
  end

  @impl true
  def data_prop_gen(params, _options \\ []) do
    DataGenerator.process_data(params, "line")
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
end
