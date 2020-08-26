defmodule AcqdatApiWeb.DashboardManagement.CommandWidgetController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Validators.DashboardManagement.CommandWidget
  import AcqdatApiWeb.Helpers
  alias AcqdatApi.DashboardManagement.CommandWidget

  plug AcqdatApiWeb.Plug.LoadPanel when action not in [:command_widget_types]
  plug AcqdatApiWeb.Plug.CommandWidget when action in [:update, :delete]

  def command_widget_types(conn, _params) do
    widget_types = CommandWidget.get_command_widget_types()

    conn
    |> put_status(200)
    |> render("command_widget_types.json", command_widget_types: widget_types)
  end

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_params(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, command_widget}} <-
               {:create, CommandWidget.create(Map.from_struct(data))} do
          conn
          |> put_status(200)
          |> render("show.json", %{command_widget: command_widget})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, %Ecto.Changeset{} = changeset}} ->
            error = extract_changeset_error(changeset)
            send_error(conn, 400, error)

          {:create, {:error, error}} ->
            send_error(conn, 400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        command_widget = conn.assigns.command_widget

        with {:update, {:ok, command_widget}} <-
               {:update, CommandWidget.update(command_widget, params)} do
          conn
          |> put_status(200)
          |> render("show.json", %{command_widget: command_widget})
        else
          {:update, {:error, %Ecto.Changeset{} = changeset}} ->
            error = extract_changeset_error(changeset)
            send_error(conn, 400, error)

          {:update, {:error, error}} ->
            send_error(conn, 400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def show(conn, _params) do
    case conn.status do
      nil ->
        command_widget = conn.assigns.command_widget

        conn
        |> put_status(200)
        |> render("show.json", %{command_widget: command_widget})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        command_widget = conn.assigns.command_widget

        with {:ok, command_widget} <- CommandWidget.delete(command_widget) do
          conn
          |> put_status(200)
          |> render("show.json", %{command_widget: command_widget})
        else
          {:error, _message} ->
            send_error(conn, 404, "Can not delete CommandWidget")
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end
end
