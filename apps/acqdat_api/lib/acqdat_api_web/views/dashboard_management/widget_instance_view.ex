defmodule AcqdatApiWeb.DashboardManagement.WidgetInstanceView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.DashboardManagement.WidgetInstanceView

  def render("show.json", %{widget_instance: widget}) do
    %{
      id: widget.id,
      widget_id: widget.widget_id,
      label: widget.label,
      uuid: widget.uuid,
      series_data: render_many(widget.series_data, WidgetInstanceView, "series_data.json"),
      visual_properties: widget.visual_properties,
      series: widget.series,
      widget_settings: widget.widget_settings,
      widget_category: widget.widget.category
    }
  end

  def render("widget_instance.json", %{widget_instance: widget}) do
    %{
      id: widget.id,
      widget_id: widget.widget_id,
      label: widget.label,
      uuid: widget.uuid
    }
  end

  def render("series_data.json", %{widget_instance: series}) do
    %{
      name: series.name,
      color: series.color,
      axes: render_many(series.axes, WidgetInstanceView, "axes.json")
    }
  end

  def render("axes.json", %{widget_instance: series}) do
    %{
      name: series.name,
      source_type: series.source_type,
      source_details: series.source_metadata
    }
  end
end
