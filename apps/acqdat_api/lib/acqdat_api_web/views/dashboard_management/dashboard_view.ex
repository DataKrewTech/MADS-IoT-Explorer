defmodule AcqdatApiWeb.DashboardManagement.DashboardView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.DashboardManagement.DashboardView
  alias AcqdatApiWeb.DashboardManagement.PanelView

  def render("dashboard.json", %{dashboard: dashboard}) do
    %{
      id: dashboard.id,
      name: dashboard.name,
      description: dashboard.description,
      org_id: dashboard.org_id,
      slug: dashboard.slug,
      uuid: dashboard.uuid,
      settings: dashboard.settings,
      avatar: dashboard.avatar
    }
  end

  def render("index.json", dashboards) do
    %{
      dashboards: render_many(dashboards.entries, DashboardView, "dashboard.json"),
      page_number: dashboards.page_number,
      page_size: dashboards.page_size,
      total_entries: dashboards.total_entries,
      total_pages: dashboards.total_pages
    }
  end

  def render("show.json", %{dashboard: dashboard}) do
    %{
      id: dashboard.id,
      name: dashboard.name,
      description: dashboard.description,
      org_id: dashboard.org_id,
      slug: dashboard.slug,
      uuid: dashboard.uuid,
      settings: dashboard.settings,
      avatar: dashboard.avatar,
      panels: render_many(dashboard.panels, PanelView, "panel.json")
    }
  end
end
