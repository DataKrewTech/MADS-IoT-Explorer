defmodule AcqdatCore.Seed.Widget do
  @moduledoc """
  Holds seeds for initial widgets.
  """
  alias AcqdatCore.Seed.Widgets.Line
  alias AcqdatCore.Seed.Widgets.Area
  alias AcqdatCore.Seed.Widgets.Pie
  alias AcqdatCore.Seed.Widgets.Bar
  alias AcqdatCore.Seed.Widgets.LineTimeseries
  alias AcqdatCore.Seed.Widgets.AreaTimeseries
  alias AcqdatCore.Seed.Widgets.GaugeSeries
  alias AcqdatCore.Seed.Widgets.SolidGauge
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
    WidgetHelpers.seed_in_elastic()
  end
end
