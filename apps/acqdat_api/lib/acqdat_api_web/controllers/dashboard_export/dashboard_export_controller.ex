defmodule AcqdatApiWeb.DashboardExport.DashboardExportController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  alias AcqdatApi.DashboardExport.DashboardExport
  import AcqdatApiWeb.Validators.DashboardExport.DashboardExport

  plug AcqdatApiWeb.Plug.LoadDashboard when action in [:create]

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_params(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, dashboard_export}} <-
               {:create, DashboardExport.create(data, conn.assigns.dashboard)} do
          url = DashboardExport.generate_url(dashboard_export)

          conn
          |> put_status(200)
          |> render("url.json", %{dashboard_export: url})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def export(conn, params) do
    case conn.status do
      nil ->
        conn
        |> put_status(200)
        |> render("exported.json", %{dashboard_export: conn.assigns.exported_dashboard})

      401 ->
        conn
        |> send_error(401, "Unauthorized link")
    end
  end
end
