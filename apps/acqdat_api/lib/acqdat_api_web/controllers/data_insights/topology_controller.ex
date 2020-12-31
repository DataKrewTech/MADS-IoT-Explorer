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

  def fact_table(conn, %{
        "org_id" => org_id,
        "project_id" => project_id,
        "fact_table_id" => id,
        "user_list" => user_list
      }) do
    case conn.status do
      nil ->
        case Topology.gen_sub_topology(id, org_id, conn.assigns.project, user_list) do
          {:error, message} ->
            conn
            |> send_error(404, message)

          data ->
            conn
            |> put_status(200)
            |> render("fact_table_data.json", %{topology: data})
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end
end
