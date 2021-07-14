defmodule AcqdatApiWeb.DataInsights.TopologyController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  alias AcqdatApi.DataInsights.Topology
  alias AcqdatCore.ElasticSearch
  alias AcqdatApiWeb.DataInsights.TopologyErrorHelper

  plug AcqdatApiWeb.Plug.LoadCurrentUser
  plug AcqdatApiWeb.Plug.LoadOrg
  plug AcqdatApiWeb.Plug.LoadProject when action in [:index, :entities]

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
        |> send_error(404, TopologyErrorHelper.error_message(:resource_not_found))
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
        |> send_error(404, TopologyErrorHelper.error_message(:resource_not_found))
    end
  end

  def fetch_projects(conn, params) do
    case conn.status do
      nil ->
        with {:ok, hits} <- ElasticSearch.project_indexing(params) do
          conn |> put_status(200) |> render("hits.json", %{hits: hits})
        else
          {:error, message} ->
            conn
            |> send_error(404, TopologyErrorHelper.error_message(:elasticsearch, message))
        end

      404 ->
        conn
        |> send_error(404, TopologyErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, TopologyErrorHelper.error_message(:unauthorized))
    end
  end
end
