defmodule AcqdatCore.Seed.Widget do
  @moduledoc """
  Holds seeds for initial widgets.
  """
  alias AcqdatCore.Seed.Widgets.{Line, Area, Pie, Bar, LineTimeseries, AreaTimeseries, GaugeSeries, SolidGauge,
        StockSingleLine, DynamicCard, ImageCard, StaticCard, BasicColumn, StackedColumn}
  alias AcqdatCore.Seed.Helpers.WidgetHelpers
  alias AcqdatCore.Repo
  alias AcqdatCore.Widgets.Schema.Widget

  def seed() do
    #Don't change the sequence it is important that widgets seeds this way.
    Line.seed()
    Area.seed()
    Pie.seed()
    Bar.seed()
    LineTimeseries.seed()
    AreaTimeseries.seed()
    GaugeSeries.seed()
    SolidGauge.seed()
    StockSingleLine.seed()
    DynamicCard.seed()
    ImageCard.seed()
    StaticCard.seed()
    BasicColumn.seed()
    StackedColumn.seed()
    WidgetHelpers.seed_in_elastic()
  end

  def update_visual_settings() do
    highcharts = %{
      "Area Range" => {AreaTimeseries, :area},
      "area" => {Area, :area},
      "bar" => {Bar, :bar},
      "Basic Column" => {BasicColumn, :column},
      "gauge" => {GaugeSeries, :gauge},
      "Line Timeseries" => {LineTimeseries, :line},
      "line" => {Line, :line},
      "pie" => {Pie, :pie},
      "solidgauge" => {SolidGauge, :solidgauge},
      "Stacked Column" => {StackedColumn, :column},
      "Stock Single line series" => {StockSingleLine, :line}
    }

    custom_widget = %{
      "Dynamic Card" => {DynamicCard, :card},
      "Image Card" => {ImageCard, :card},
      "Static Card" => {StaticCard, :card}
    }

    Enum.each(highcharts, fn {label, value} ->
      {module, widget_key} = value
      module.update_visual_settings(label, widget_key)
    end)

  end
end
