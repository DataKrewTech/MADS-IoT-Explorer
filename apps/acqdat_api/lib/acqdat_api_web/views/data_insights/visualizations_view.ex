defmodule AcqdatApiWeb.DataInsights.VisualizationsView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.DataInsights.VisualizationsView
  alias AcqdatApiWeb.DashboardManagement.PanelView

  def render("type_detail.json", %{visualizations: visualization}) do
    %{
      name: visualization.name,
      type: visualization.type,
      module: visualization.module,
      icon_id: visualization.icon_id,
      visual_settings: visualization.visual_settings,
      data_settings: visualization.data_settings
    }
  end

  def render("create.json", %{visualization: visualization}) do
    %{
      id: visualization.id,
      fact_table_id: visualization.fact_table_id,
      name: visualization.name,
      type: visualization.type,
      module: visualization.module,
      visual_settings: visualization.visual_settings,
      data_settings: visualization.data_settings
    }
  end

  def render("all_types.json", %{types: types}) do
    %{
      visualizations: render_many(types, VisualizationsView, "type_detail.json")
    }
  end

  def render("visualization_data.json", %{visualization_data: visualization}) do
    %{
      id: visualization.id,
      name: visualization.name,
      project_id: visualization.project_id,
      org_id: visualization.org_id,
      slug: visualization.slug,
      uuid: visualization.uuid,
      type: visualization.type,
      module: visualization.module,
      visual_settings: visualization.visual_settings,
      data_settings: visualization.data_settings,
      created_at: visualization.inserted_at,
      gen_data: visualization.gen_data
    }
  end

  def render("visualization_data_error.json", %{visualization_data: visualization}) do
    %{visualization: visualization}
  end

  def render("creator.json", %{visualizations: creator}) do
    %{
      id: creator.id,
      email: creator.email,
      first_name: creator.first_name,
      last_name: creator.last_name
    }
  end

  def render("visualization.json", %{visualizations: visualization}) do
    %{
      id: visualization.id,
      name: visualization.name,
      module: visualization.module,
      project_id: visualization.project_id,
      org_id: visualization.org_id,
      slug: visualization.slug,
      uuid: visualization.uuid,
      type: visualization.type,
      module: visualization.module,
      icon_id: visualization.module.icon_id,
      visual_settings: visualization.visual_settings,
      data_settings: visualization.data_settings,
      created_at: visualization.inserted_at,
      creator: render_one(visualization.creator, VisualizationsView, "creator.json")
    }
  end

  def render("index.json", visualizations) do
    %{
      visualizations:
        render_many(visualizations.entries, VisualizationsView, "visualization.json"),
      page_number: visualizations.page_number,
      page_size: visualizations.page_size,
      total_entries: visualizations.total_entries,
      total_pages: visualizations.total_pages
    }
  end

  def render("widget_show.json", %{visualization: widget}) do
    %{
      id: widget.id,
      widget_id: widget.widget_id,
      label: widget.label,
      uuid: widget.uuid,
      source_app: widget.source_app,
      source_metadata: widget.source_metadata,
      visual_properties: widget.visual_properties,
      panel: render_one(widget.panel, PanelView, "panel.json")
    }
  end
end
