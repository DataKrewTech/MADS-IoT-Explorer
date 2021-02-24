defmodule AcqdatApiWeb.DataInsights.VisualizationsController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  alias AcqdatApi.DataInsights.Visualizations

  plug AcqdatApiWeb.Plug.LoadCurrentUser
  plug AcqdatApiWeb.Plug.LoadProject
  # plug AcqdatApiWeb.Plug.LoadVisualizations when action in [:update, :delete, :show]

  def fetch_all_types(conn, _params) do
    case conn.status do
      nil ->
        {:list, visual_types} = {:list, Visualizations.get_all_visualization_types()}

        conn
        |> put_status(200)
        |> render("all_types.json", %{types: visual_types})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
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
        |> send_error(404, "Resource Not Found")

      401 ->
        conn
        |> send_error(401, "Unauthorized")
    end
  end
end
