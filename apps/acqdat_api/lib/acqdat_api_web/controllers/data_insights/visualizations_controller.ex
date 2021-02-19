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
        {:list, visual_types} = {:list, %{types: Visualizations.get_all_visualization_types()}}

        conn
        |> put_status(200)
        |> render("all_types.json", visual_types)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end
end
