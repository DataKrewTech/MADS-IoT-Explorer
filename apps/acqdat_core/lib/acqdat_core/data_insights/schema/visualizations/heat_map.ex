defmodule AcqdatCore.DataInsights.Schema.Visualizations.HeatMap do
  use AcqdatCore.Schema
  alias AcqdatCore.DataInsights.Domain.DataGenerator

  @behaviour AcqdatCore.DataInsights.Schema.Visualizations
  @visualization_type "HeatMap"
  @visualization_name "HeatMap"
  @icon_id "heat-map"

  defstruct data_settings: %{
              x_axes: [],
              y_axes: [],
              values: [],
              filters: []
            },
            visual_settings: %{}

  @impl true
  def visual_prop_gen(_visualization, options \\ %{}) do
    DataGenerator.process_visual_data(options, "heat_map")
  end

  @impl true
  def data_prop_gen(params, _options \\ []) do
    DataGenerator.process_data(params)
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
