defmodule AcqdatCore.Seed.Widget do
  @moduledoc """
  Holds seeds for initial widgets.
  """
  alias AcqdatCore.Seed.Widgets.{Line, Area, Pie, Bar, LineTimeseries, AreaTimeseries, GaugeSeries, SolidGauge, StockSingleLine}
  alias AcqdatCore.Seed.Helpers.WidgetHelpers

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
    WidgetHelpers.seed_in_elastic()
  end
end
