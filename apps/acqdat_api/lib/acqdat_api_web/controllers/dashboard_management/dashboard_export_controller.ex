defmodule AcqdatApiWeb.DashboardManagement.DashboardExportController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  alias AcqdatApi.DashboardExport.DashboardExport
  alias AcqdatApi.DashboardManagement.{Dashboard, WidgetInstance}
  alias AcqdatCore.Model.EntityManagement.Organisation, as: OrgModel
  alias AcqdatApiWeb.DashboardManagement.DashboardExportErrorHelper
  alias AcqdatApiWeb.Validators.DashboardExport.DashboardExport, as: ExportValidator

  plug AcqdatApiWeb.Plug.LoadDashboard when action in [:create]
  plug :put_view, AcqdatApiWeb.DashboardManagement.PanelView when action in [:show]
  plug :put_view, AcqdatApiWeb.EntityManagement.EntityView when action in [:fetch_all_hierarchy]

  plug :put_view,
       AcqdatApiWeb.DashboardManagement.WidgetInstanceView
       when action in [:fetch_widget_instances]

  plug AcqdatApiWeb.Plug.LoadPanel when action in [:show, :fetch_widget_instances]

  plug :put_view,
       AcqdatApiWeb.DashboardManagement.DashboardView when action in [:exported_dashboard]

  plug AcqdatApiWeb.Plug.LoadDashboardExport when action in [:update, :show_credentials]

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = ExportValidator.from(params, with: &ExportValidator.verify_params/2)

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
        |> send_error(404, DashboardExportErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, DashboardExportErrorHelper.error_message(:unauthorized))
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        exported_dashboard = conn.assigns.exported_dashboard
        changeset = ExportValidator.from(params, with: &ExportValidator.verify_update_params/2)

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
            send_error(
              conn,
              400,
              DashboardExportErrorHelper.error_message(:updation_error, message)
            )
        end

      404 ->
        conn
        |> send_error(404, DashboardExportErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, DashboardExportErrorHelper.error_message(:unauthorized))
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
        |> send_error(404, DashboardExportErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, DashboardExportErrorHelper.error_message(:unauthorized))
    end
  end

  def export(conn, params) do
    case conn.status do
      nil ->
        conn
        |> put_status(200)
        |> render("exported.json", %{dashboard_export: conn.assigns.exported_dashboard})

      404 ->
        conn
        |> send_error(404, DashboardExportErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, DashboardExportErrorHelper.error_message(:unauthorized))
    end
  end

  def show(conn, params) do
    case conn.status do
      nil ->
        case Dashboard.get_panels_data(params) do
          {:error, message} ->
            send_error(conn, 400, message)

          {:ok, panel} ->
            conn
            |> put_status(200)
            |> render("show.json", %{panel: panel})
        end

      404 ->
        conn
        |> send_error(404, DashboardExportErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, DashboardExportErrorHelper.error_message(:unauthorized))
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
            |> send_error(401, DashboardExportErrorHelper.error_message(:unauthorized))
        end

      404 ->
        conn
        |> send_error(404, DashboardExportErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, DashboardExportErrorHelper.error_message(:unauthorized))
    end
  end

  def fetch_widget_instances(conn, %{"id" => id} = params) do
    case conn.status do
      nil ->
        {id, _} = Integer.parse(id)

        case WidgetInstance.get_by_filter(id, params) do
          {:error, message} ->
            conn
            |> send_error(400, DashboardExportErrorHelper.error_message(:resource_not_found))

          {:ok, widget_instance} ->
            conn
            |> put_status(200)
            |> render("show.json", %{widget_instance: widget_instance})
        end

      404 ->
        conn
        |> send_error(404, DashboardExportErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, DashboardExportErrorHelper.error_message(:unauthorized))
    end
  end

  def reports(conn, params) do
    case conn.status do
      nil ->
        case Dashboard.gen_report(params) do
          {:ok, message} ->
            conn
            |> put_status(200)
            |> render("report.json", %{dashboard_export: message})

          {:error, message} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, DashboardExportErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, DashboardExportErrorHelper.error_message(:unauthorized))
    end
  end

  def fetch_all_hierarchy(conn, %{"org_id" => org_id}) do
    case conn.status do
      nil ->
        {org_id, _} = Integer.parse(org_id)

        case OrgModel.fetch_hierarchy_by_all_projects(org_id) do
          {:ok, org} ->
            conn
            |> put_status(200)
            |> render("organisation_tree.json", %{org: org})

          {:error, _message} ->
            conn
            |> send_error(404, DashboardExportErrorHelper.error_message(:resource_not_found))
        end

      404 ->
        conn
        |> send_error(404, DashboardExportErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, DashboardExportErrorHelper.error_message(:unauthorized))
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
