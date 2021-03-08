defmodule AcqdatCore.DataInsights.Schema.Visualizations.Column do
  use AcqdatCore.Schema
  alias AcqdatCore.DataInsights.Domain.DataGenerator

  @behaviour AcqdatCore.DataInsights.Schema.Visualizations
  @visualization_type "Column"
  @visualization_name "Column"
  @icon_id "column-chart"

  defstruct data_settings: %{
              x_axes: [],
              y_axes: [],
              legends: [],
              filters: []
            },
            visual_settings: %{}

  @impl true
  def visual_prop_gen(visualization, options \\ %{}) do
    if options[:chart_category] && options[:chart_category] == "highchart" do
      %{
        chart: %{
          type: "column"
        },
        xAxis: %{
          type: "category"
        },
        legend: %{enabled: true}
      }
    else
      %{
        chart: %{
          type: "column"
        },
        legend: %{enabled: true}
      }
    end
  end

  @impl true
  def data_prop_gen(params, _options \\ []) do
    DataGenerator.process(params)
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
