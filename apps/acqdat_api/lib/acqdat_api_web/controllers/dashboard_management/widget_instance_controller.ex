defmodule AcqdatApiWeb.DashboardManagement.WidgetInstanceController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.DashboardManagement.WidgetInstance
  alias AcqdatApi.DashboardManagement.WidgetInstance

  plug AcqdatApiWeb.Plug.LoadOrg
  plug AcqdatApiWeb.Plug.LoadPanel
  plug AcqdatApiWeb.Plug.LoadWidget
  plug AcqdatApiWeb.Plug.LoadWidgetInstance when action in [:update, :delete]

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_params(params)

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

  def update(conn, params) do
    case conn.status do
      nil ->
        case WidgetInstance.update(conn.assigns.widget_instance, params) do
          {:ok, widget_inst} ->
            conn
            |> put_status(200)
            |> render("show.json", %{widget_instance: widget_inst})

          {:error, message} ->
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

        case WidgetInstance.get_by_filter(id, params) do
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

  def delete(conn, _params) do
    case conn.status do
      nil ->
        case WidgetInstance.delete(conn.assigns.widget_instance) do
          {:ok, widget_instance} ->
            conn
            |> put_status(200)
            |> render("widget_instance.json", %{widget_instance: widget_instance})

          {:error, widget_instance} ->
            error =
              case String.valid?(widget_instance) do
                false -> extract_changeset_error(widget_instance)
                true -> widget_instance
              end

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end
end
