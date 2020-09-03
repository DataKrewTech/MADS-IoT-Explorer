defmodule AcqdatApiWeb.DashboardManagement.PanelController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.DashboardManagement.Panel
  alias AcqdatApi.DashboardManagement.Panel

  plug AcqdatApiWeb.Plug.LoadOrg
  plug AcqdatApiWeb.Plug.LoadPanel when action in [:update, :delete]

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, panels} = {:list, Panel.get_all(data)}

        conn
        |> put_status(200)
        |> render("index.json", panels)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_create(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, panel}} <- {:create, Panel.create(data)} do
          conn
          |> put_status(200)
          |> render("panel.json", %{panel: panel})
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

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        case Panel.update(conn.assigns.panel, params) do
          {:ok, panel} ->
            conn
            |> put_status(200)
            |> render("panel.json", %{panel: panel})

          {:error, panel} ->
            error =
              case String.valid?(panel) do
                false -> extract_changeset_error(panel)
                true -> panel
              end

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        case Panel.delete(conn.assigns.panel) do
          {:ok, panel} ->
            conn
            |> put_status(200)
            |> render("panel.json", %{panel: panel})

          {:error, panel} ->
            error =
              case String.valid?(panel) do
                false -> extract_changeset_error(panel)
                true -> panel
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
