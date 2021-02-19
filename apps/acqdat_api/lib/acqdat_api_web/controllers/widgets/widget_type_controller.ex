defmodule AcqdatApiWeb.Widgets.WidgetTypeController do
  use AcqdatApiWeb, :authorized_controller
  alias AcqdatApi.Widgets.WidgetType
  alias AcqdatCore.Model.Widgets.WidgetType, as: WTModel
  alias AcqdatApiWeb.Widgets.WidgetTypeErrorHelper
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.Widgets.WidgetType

  plug :load_widget_type when action in [:update, :show, :delete]

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, widget_type} = {:list, WTModel.get_all(data)}

        conn
        |> put_status(200)
        |> render("index.json", widget_type)

      404 ->
        conn
        |> send_error(404, WidgetTypeErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, WidgetTypeErrorHelper.error_message(:unauthorized))
    end
  end

  def create(conn, params) do
    changeset = verify_widget_type_params(params)

    with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
         {:create, {:ok, widget_type}} <- {:create, WidgetType.create(data)} do
      conn
      |> put_status(200)
      |> render("widget_type.json", %{widget_type: widget_type})
    else
      {:extract, {:error, error}} ->
        error = extract_changeset_error(error)
        send_error(conn, 400, error)

      {:create, {:error, message}} ->
        error = extract_changeset_error(message)
        send_error(conn, 400, error)
    end
  end

  def show(conn, _params) do
    case conn.status do
      nil ->
        conn
        |> put_status(200)
        |> render("widget_type.json", %{widget_type: conn.assigns.widget_type})

      404 ->
        conn
        |> send_error(404, WidgetTypeErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, WidgetTypeErrorHelper.error_message(:unauthorized))
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        case WTModel.delete(conn.assigns.widget_type) do
          {:ok, widget_type} ->
            conn
            |> put_status(200)
            |> render("widget_type.json", %{widget_type: widget_type})

          {:error, widget_type} ->
            error = extract_changeset_error(widget_type)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, WidgetTypeErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, WidgetTypeErrorHelper.error_message(:unauthorized))
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{widget_type: widget_type}} = conn

        case WTModel.update(widget_type, params) do
          {:ok, widget_type} ->
            conn
            |> put_status(200)
            |> render("widget_type.json", %{widget_type: widget_type})

          {:error, widget_type} ->
            error = extract_changeset_error(widget_type)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, WidgetTypeErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, WidgetTypeErrorHelper.error_message(:unauthorized))
    end
  end

  defp load_widget_type(%{params: %{"id" => widget_type_id}} = conn, _params) do
    {widget_type_id, _} = Integer.parse(widget_type_id)

    case WTModel.get(widget_type_id) do
      {:ok, widget_type} ->
        assign(conn, :widget_type, widget_type)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
