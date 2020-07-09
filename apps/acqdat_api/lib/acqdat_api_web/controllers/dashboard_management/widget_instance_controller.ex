defmodule AcqdatApiWeb.DashboardManagement.WidgetInstanceController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.DashboardManagement.WidgetInstance
  alias AcqdatApi.DashboardManagement.WidgetInstance

  plug AcqdatApiWeb.Plug.LoadOrg
  plug AcqdatApiWeb.Plug.LoadDashboard
  plug AcqdatApiWeb.Plug.LoadWidget

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_create(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, widget_inst}} <- {:create, WidgetInstance.create(data, conn)} do
          conn
          |> put_status(200)
          |> render("show.json", %{widget_instance: widget_inst})
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

  def show(conn, %{"id" => id} = params) do
    case conn.status do
      nil ->
        {id, _} = Integer.parse(id)
        filter_month = params["filter_month"] || "1"

        case WidgetInstance.get_by_filter(
               id,
               filter_month,
               params["start_date"],
               params["end_date"]
             ) do
          {:error, message} ->
            send_error(conn, 400, message)

          {:ok, widget_instance} ->
            conn
            |> put_status(200)
            |> render("show.json", %{widget_instance: widget_instance})
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end
end
