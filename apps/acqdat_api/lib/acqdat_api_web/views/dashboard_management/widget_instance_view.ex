defmodule AcqdatApiWeb.DashboardManagement.WidgetInstanceView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.DashboardManagement.WidgetInstanceView

  def render("show.json", %{widget_inst: widget}) do
    %{
      id: widget.id,
      widget_id: widget.widget_id,
      label: widget.label,
      properties: widget.properties,
      default_values: widget.default_values,
      uuid: widget.uuid,
      visual_settings: render_many(widget.visual_settings, WidgetInstanceView, "visual_settings.json"),
      data_settings: render_many(widget.data_settings, WidgetInstanceView, "data_settings.json"),
      series_data: render_many(widget.series_data, WidgetInstanceView, "series_data.json")
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

  def render("visual_settings.json", %{widget_instance: settings}) do
    %{
      key: settings.key,
      data_type: settings.data_type,
      value: settings.value["data"] || "",
      properties: render_many(settings.properties, WidgetInstanceView, "visual_settings.json")
    }
  end

  def render("data_settings.json", %{widget_instance: settings}) do
    %{
      key: settings.key,
      data_type: settings.data_type,
      value: settings.value["data"] || "",
      properties: render_many(settings.properties, WidgetInstanceView, "data_settings.json")
    }
  end
end