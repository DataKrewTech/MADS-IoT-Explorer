defmodule AcqdatApiWeb.DashboardManagement.PanelView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.DashboardManagement.PanelView
  alias AcqdatApiWeb.DashboardManagement.WidgetInstanceView
  alias AcqdatApiWeb.DashboardManagement.CommandWidgetView

  def render("delete_all.json", %{message: message}) do
    %{
      status: message
    }
  end

  def render("panel.json", %{panel: panel}) do
    %{
      id: panel.id,
      name: panel.name,
      description: panel.description,
      org_id: panel.org_id,
      dashboard_id: panel.dashboard_id,
      slug: panel.slug,
      uuid: panel.uuid,
      settings: panel.settings,
      widget_layouts: panel.widget_layouts
    }
  end

  def render("index.json", panels) do
    %{
      panels: render_many(panels.entries, PanelView, "panel.json"),
      page_number: panels.page_number,
      page_size: panels.page_size,
      total_entries: panels.total_entries,
      total_pages: panels.total_pages
    }
  end

  def render("show.json", %{panel: panel}) do
    %{
      id: panel.id,
      name: panel.name,
      description: panel.description,
      org_id: panel.org_id,
      dashboard_id: panel.dashboard_id,
      slug: panel.slug,
      uuid: panel.uuid,
      settings: panel.settings,
      widget_layouts: panel.widget_layouts,
      widgets: render_many(panel.widgets, WidgetInstanceView, "show.json"),
      command_widgets: render_many(panel.command_widgets, CommandWidgetView, "show.json")
    }
  end
end
