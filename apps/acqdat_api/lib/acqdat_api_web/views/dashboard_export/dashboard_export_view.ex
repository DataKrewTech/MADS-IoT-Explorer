defmodule AcqdatApiWeb.DashboardExport.DashboardExportView do
  use AcqdatApiWeb, :view

  def render("url.json", %{dashboard_export: url}) do
    %{
      url: url
    }
  end

  def render("exported.json", %{dashboard_export: dashboard_export}) do
    %{
      dashboard_uuid: dashboard_export.dashboard_uuid,
      is_secure: dashboard_export.is_secure
    }
  end

  def render("show_credentials.json", %{dashboard_export: dashboard_export}) do
    %{
      password: dashboard_export.password,
      is_secure: dashboard_export.is_secure
    }
  end
end
