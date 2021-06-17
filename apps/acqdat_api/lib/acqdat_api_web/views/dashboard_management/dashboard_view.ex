defmodule AcqdatApiWeb.DashboardManagement.DashboardView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.DashboardManagement.DashboardView
  alias AcqdatApiWeb.DashboardManagement.PanelView
  alias AcqdatCore.Repo

  def render("dashboard.json", %{dashboard: dashboard}) do
    dashboard = Repo.preload(dashboard, [:panels, :dashboard_export, creator: :user_credentials])

    %{
      id: dashboard.id,
      name: dashboard.name,
      description: dashboard.description,
      org_id: dashboard.org_id,
      slug: dashboard.slug,
      uuid: dashboard.uuid,
      archived: dashboard.archived,
      opened_on: dashboard.opened_on,
      settings: render_one(dashboard.settings, DashboardView, "settings.json"),
      avatar: dashboard.avatar,
      creator: render_one(dashboard.creator, DashboardView, "creator.json"),
      panels: render_many(dashboard.panels, PanelView, "panel.json"),
      exported_url:
        render_one(dashboard.dashboard_export, DashboardView, "exported_dashboard.json")
    }
  end

  def render("creator.json", %{dashboard: %{user_credentials: user_cred}}) do
    %{
      email: user_cred.email,
      first_name: user_cred.first_name,
      last_name: user_cred.last_name
    }
  end

  def render("report.json", %{dashboard: message}) do
    %{
      message: message
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
      archived: dashboard.archived,
      settings: render_one(dashboard.settings, DashboardView, "settings.json"),
      avatar: dashboard.avatar,
      panels: render_many(dashboard.panels, PanelView, "panel.json"),
      exported_url:
        render_one(dashboard.dashboard_export, DashboardView, "exported_dashboard.json"),
      creator: render_one(dashboard.creator, DashboardView, "creator.json")
    }
  end

  def render("exported_dashboard.json", %{dashboard: export_details}) do
    %{
      url: export_details.url,
      is_secure: export_details.is_secure,
      shared_on: export_details.inserted_at,
      password: export_details.password
    }
  end

  def render("settings.json", %{dashboard: settings}) do
    %{
      id: settings.id,
      background_color: settings.background_color,
      client_name: settings.client_name,
      sidebar_color: settings.sidebar_color,
      client_logo: settings.client_logo,
      panels_order: settings.panels_order,
      timezone: settings.timezone,
      selected_panel_color: settings.selected_panel_color
    }
  end
end
