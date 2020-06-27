defmodule AcqdatApiWeb.DashboardManagement.DashboardView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.DashboardManagement.DashboardView

  def render("dashboard.json", %{dashboard: dashboard}) do
    %{
      id: dashboard.id,
      name: dashboard.name,
      org_id: dashboard.org_id,
      slug: dashboard.slug,
      uuid: dashboard.uuid,
      project_id: dashboard.project_id,
      settings: dashboard.settings
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
end
