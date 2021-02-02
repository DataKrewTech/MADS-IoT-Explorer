defmodule AcqdatApiWeb.DashboardManagement.DashboardExportController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  alias AcqdatApi.DashboardExport.DashboardExport
  alias AcqdatApi.DashboardManagement.Panel
  alias AcqdatApi.DashboardManagement.Dashboard
  import AcqdatApiWeb.Validators.DashboardExport.DashboardExport

  plug AcqdatApiWeb.Plug.LoadDashboard when action in [:create]
  plug :put_view, AcqdatApiWeb.DashboardManagement.PanelView when action in [:show]
  plug AcqdatApiWeb.Plug.LoadPanel when action in [:show]

  plug :put_view,
       AcqdatApiWeb.DashboardManagement.DashboardView when action in [:exported_dashboard]

  plug AcqdatApiWeb.Plug.LoadDashboardExport when action in [:update, :show_credentials]

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_params(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, dashboard_export}} <-
               {:create, DashboardExport.create(data, conn.assigns.dashboard)} do
          conn
          |> put_status(200)
          |> render("url.json", %{dashboard_export: dashboard_export.url})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")

      401 ->
        conn
        |> send_error(401, "Unauthorized")
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        exported_dashboard = conn.assigns.exported_dashboard
        changeset = verify_update_params(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:update, {:ok, dashboard_export}} <-
               {:update, DashboardExport.update(exported_dashboard, data)} do
          conn
          |> put_status(200)
          |> render("exported.json", %{dashboard_export: dashboard_export})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:update, {:error, message}} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")

      401 ->
        conn
        |> send_error(401, "Unauthorized")
    end
  end

  def show_credentials(conn, _params) do
    case conn.status do
      nil ->
        conn
        |> put_status(200)
        |> render("show_credentials.json", %{dashboard_export: conn.assigns.exported_dashboard})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")

      401 ->
        conn
        |> send_error(401, "Unauthorized")
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

  def show(conn, %{"id" => id}) do
    case conn.status do
      nil ->
        {id, _} = Integer.parse(id)

        case Panel.get_with_widgets(id) do
          {:error, message} ->
            send_error(conn, 400, message)

          {:ok, panel} ->
            conn
            |> put_status(200)
            |> render("show.json", %{panel: panel})
        end

      401 ->
        conn
        |> send_error(401, "Unauthorized link")

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def exported_dashboard(conn, params) do
    case conn.status do
      nil ->
        exported_dashboard = conn.assigns.exported_dashboard

        dashboard =
          check_exported_dashboard(exported_dashboard.is_secure, params, exported_dashboard)

        case dashboard do
          {:ok, dashboard} ->
            conn
            |> put_status(200)
            |> render("show.json", %{dashboard: dashboard})

          {:error, message} ->
            send_error(conn, 400, message)

          nil ->
            conn
            |> send_error(401, "Unauthorized link")
        end

      401 ->
        conn
        |> send_error(401, "Unauthorized link")
    end
  end

  ############################# private functions ###########################
  defp check_exported_dashboard(true, params, exported_dashboard) do
    case check_password(params["password"], exported_dashboard.password) do
      false ->
        nil

      true ->
        Dashboard.get_by_uuid(exported_dashboard.dashboard_uuid)
    end
  end

  defp check_exported_dashboard(false, params, exported_dashboard) do
    Dashboard.get_by_uuid(exported_dashboard.dashboard_uuid)
  end

  defp check_password(password, db_password) do
    if password == db_password do
      true
    else
      false
    end
  end
end
