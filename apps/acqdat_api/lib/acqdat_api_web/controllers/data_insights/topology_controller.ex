defmodule AcqdatApiWeb.DataInsights.TopologyController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Model.EntityManagement.Project

  plug AcqdatApiWeb.Plug.LoadCurrentUser
  plug AcqdatApiWeb.Plug.LoadOrg
  plug AcqdatApiWeb.Plug.LoadProject

  def index(conn, %{"org_id" => org_id, "project_id" => project_id}) do
    case conn.status do
      nil ->
        with {:index, topology} <-
               {:index, Project.gen_topology(org_id, project_id)} do
          conn
          |> put_status(200)
          |> render("index.json", topology: topology)
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
