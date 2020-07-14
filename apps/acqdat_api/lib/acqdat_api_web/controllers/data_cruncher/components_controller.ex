defmodule AcqdatApiWeb.DataCruncher.ComponentsController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.DataCruncher.Model.ComponentHelper

  plug AcqdatApiWeb.Plug.LoadCurrentUser when action in [:create]
  plug AcqdatApiWeb.Plug.LoadOrg when action in [:create]

  def index(conn, _params) do
    case conn.status do
      nil ->
        with {:index, components} <-
               {:index, ComponentHelper.all_components()} do
          conn
          |> put_status(200)
          |> render("index.json", components: components)
        else
          {:create, {:error, error}} ->
            send_error(conn, 400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end
end
