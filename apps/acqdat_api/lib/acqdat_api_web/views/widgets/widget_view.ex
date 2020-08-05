defmodule AcqdatApiWeb.Widgets.WidgetView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.Widgets.WidgetTypeView
  alias AcqdatApiWeb.Widgets.WidgetView

  def render("widget.json", %{widget: widget}) do
    %{
      id: widget.id,
      widget_type_id: widget.widget_type_id,
      label: widget.label,
      classification: widget.classification,
      properties: widget.properties,
      policies: widget.policies,
      category: widget.category,
      default_values: widget.default_values,
      image_url: widget.image_url,
      uuid: widget.uuid,
      widget_type: render_one(widget.widget_type, WidgetTypeView, "widget_type.json"),
      visual_settings: render_many(widget.visual_settings, WidgetView, "visual_settings.json"),
      data_settings: render_many(widget.data_settings, WidgetView, "data_settings.json"),
      visual_prop: widget.visual_prop,
      data_prop: widget.data_prop
    }
  end

  def render("index.json", widget_type) do
    %{
      widgets: render_many(widget_type.entries, WidgetView, "widget_index.json"),
      page_number: widget_type.page_number,
      page_size: widget_type.page_size,
      total_entries: widget_type.total_entries,
      total_pages: widget_type.total_pages
    }
  end

  def render("fetch_all.json", %{data: data}) do
    %{
      data: render_many(data, WidgetView, "widget_data.json")
    }
  end

  def render("widget_data.json", %{widget: data}) do
    %{
      classification: data.classification,
      count: data.count,
      widgets: render_many(data.widgets, WidgetView, "widget_details.json")
    }
  end

  def render("widget_details.json", %{widget: widget}) do
    %{
      id: widget["id"],
      widget_type_id: widget["widget_type_id"],
      label: widget["label"],
      classification: widget["classification"],
      properties: widget["properties"],
      policies: widget["policies"],
      category: widget["category"],
      image_url: widget["image_url"],
      uuid: widget["uuid"]
    }
  end

  def render("widget_show.json", %{widget: widget}) do
    %{
      id: widget.id,
      widget_type_id: widget.widget_type_id,
      label: widget.label,
      classification: widget.classification,
      properties: widget.properties,
      policies: widget.policies,
      category: widget.category,
      image_url: widget.image_url,
      uuid: widget.uuid
    }
  end

  def render("visual_settings.json", %{widget: settings}) do
    %{
      key: settings.key,
      data_type: settings.data_type,
      value: settings.value["data"] || "",
      properties: render_many(settings.properties, WidgetView, "visual_settings.json")
    }
  end

  def render("data_settings.json", %{widget: settings}) do
    %{
      key: settings.key,
      data_type: settings.data_type,
      value: settings.value["data"] || "",
      properties: render_many(settings.properties, WidgetView, "data_settings.json")
    }
  end

  def render("widget_index.json", %{widget: widget}) do
    %{
      id: widget.id,
      widget_type_id: widget.widget_type_id,
      label: widget.label,
      classification: widget.classification,
      properties: widget.properties,
      policies: widget.policies,
      category: widget.category,
      image_url: widget.image_url,
      uuid: widget.uuid,
      widget_type: render_one(widget.widget_type, WidgetTypeView, "widget_type.json")
    }
  end

  def render("hits.json", %{hits: hits}) do
    %{
      widgets: render_many(hits.hits, WidgetView, "source.json")
    }
  end

  def render("source.json", %{widget: %{_source: hits}}) do
    %{
      id: hits.id,
      category: hits.category,
      label: hits.label,
      properties: hits.properties,
      uuid: hits.uuid
    }
  end
end
