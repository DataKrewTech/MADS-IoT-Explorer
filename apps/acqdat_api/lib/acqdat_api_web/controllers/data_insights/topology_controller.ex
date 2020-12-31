defmodule AcqdatApiWeb.DataInsights.TopologyController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  alias AcqdatApi.DataInsights.Topology

  plug AcqdatApiWeb.Plug.LoadCurrentUser
  plug AcqdatApiWeb.Plug.LoadOrg
  plug AcqdatApiWeb.Plug.LoadProject

  def index(conn, %{"org_id" => org_id, "project_id" => project_id}) do
    case conn.status do
      nil ->
        with {:index, topology} <-
               {:index, Topology.gen_topology(org_id, conn.assigns.project)} do
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

  def entities(conn, %{"org_id" => org_id, "project_id" => project_id}) do
    case conn.status do
      nil ->
        with {:index, topology} <-
               {:index, Topology.entities(%{org_id: org_id, project_id: project_id})} do
          conn
          |> put_status(200)
          |> render("details.json", topology)
        else
          {:index, {:error, error}} ->
            send_error(conn, 400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end
end
