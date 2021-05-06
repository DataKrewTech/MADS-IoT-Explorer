defmodule AcqdatApiWeb.DataInsights.VisualizationsController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.DataInsights.Visualizations
  alias AcqdatApi.DataInsights.Visualizations
  alias AcqdatApiWeb.DataInsights.VisualizationsErrorHelper

  plug AcqdatApiWeb.Plug.LoadCurrentUser
  plug AcqdatApiWeb.Plug.LoadProject
  plug AcqdatApiWeb.Plug.LoadVisualizations when action in [:update, :delete, :show, :export]

  def fetch_all_types(conn, _params) do
    case conn.status do
      nil ->
        {:list, visual_types} = {:list, Visualizations.get_all_visualization_types()}

        conn
        |> put_status(200)
        |> render("all_types.json", %{types: visual_types})

      404 ->
        conn
        |> send_error(404, VisualizationsErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, VisualizationsErrorHelper.error_message(:unauthorized))
    end
  end

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, visualizations} = {:list, Visualizations.get_all(data)}

        conn
        |> put_status(200)
        |> render("index.json", visualizations)

      404 ->
        conn
        |> send_error(404, VisualizationsErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, VisualizationsErrorHelper.error_message(:unauthorized))
    end
  end

  def create(conn, params) do
    case conn.status do
      nil ->
        case Visualizations.create(params) do
          {:error, %Ecto.Changeset{} = changeset} ->
            error = extract_changeset_error(changeset)
            send_error(conn, 400, error)

          {:error, message} ->
            conn
            |> send_error(404, message)

          {:ok, data} ->
            conn
            |> put_status(200)
            |> render("create.json", %{visualization: data})
        end

      404 ->
        conn
        |> send_error(404, VisualizationsErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, VisualizationsErrorHelper.error_message(:unauthorized))
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        case Visualizations.update(conn.assigns.visualizations, params) do
          {:error, %Ecto.Changeset{} = changeset} ->
            error = extract_changeset_error(changeset)
            send_error(conn, 400, error)

          {:error, message} ->
            conn
            |> send_error(404, message)

          {:ok, data} ->
            conn
            |> put_status(200)
            |> render("create.json", %{visualization: data})
        end

      404 ->
        conn
        |> send_error(404, VisualizationsErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, VisualizationsErrorHelper.error_message(:unauthorized))
    end
  end

  def show(conn, _params) do
    case conn.status do
      nil ->
        conn
        |> put_status(200)
        |> render("create.json", %{visualization: conn.assigns.visualizations})

      404 ->
        conn
        |> send_error(404, VisualizationsErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, VisualizationsErrorHelper.error_message(:unauthorized))
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        case Visualizations.delete(conn.assigns.visualizations) do
          {:ok, visualization} ->
            conn
            |> put_status(200)
            |> render("create.json", %{visualization: visualization})

          {:error, %Ecto.Changeset{} = changeset} ->
            error = extract_changeset_error(changeset)
            send_error(conn, 400, error)

          {:error, message} ->
            conn
            |> send_error(404, message)
        end

      404 ->
        conn
        |> send_error(404, VisualizationsErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, VisualizationsErrorHelper.error_message(:unauthorized))
    end
  end

  def export(conn, params) do
    case conn.status do
      nil ->
        case Visualizations.export(conn.assigns.visualizations, params) do
          {:ok, widget} ->
            conn
            |> put_status(200)
            |> render("widget_show.json", %{visualization: widget})

          {:error, %Ecto.Changeset{} = changeset} ->
            error = extract_changeset_error(changeset)
            send_error(conn, 400, error)

          {:error, message} ->
            conn
            |> send_error(404, message)
        end

      404 ->
        conn
        |> send_error(404, VisualizationsErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, VisualizationsErrorHelper.error_message(:unauthorized))
    end
  end
end
