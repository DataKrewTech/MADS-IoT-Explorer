defmodule AcqdatApiWeb.EntityManagement.EntityController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.EntityManagement.EntityParser
  alias AcqdatCore.Model.EntityManagement.Organisation, as: OrgModel
  import AcqdatApiWeb.Helpers

  plug AcqdatApiWeb.Plug.LoadOrg when action in [:update_hierarchy]
  plug :load_hierarchy_tree when action in [:fetch_hierarchy]

  def update_hierarchy(conn, %{"id" => org_id, "type" => type, "entities" => entities} = params) do
    case conn.status do
      nil ->
        org = conn.assigns.org

        with {:ok, _data} <- EntityParser.parse(entities, org_id, nil, type, params) do
          conn |> put_status(200) |> render("organisation_tree.json", org)
        else
          {:error, message} ->
            conn
            |> put_status(404)
            |> json(%{
              "success" => false,
              "error" => true,
              "message:" => message
            })
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def fetch_hierarchy(conn, _params) do
    case conn.status do
      nil ->
        org = conn.assigns.org

        conn
        |> put_status(200)
        |> render("organisation_tree.json", org)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp load_hierarchy_tree(
         %{params: %{"org_id" => org_id, "project_id" => project_id}} = conn,
         _params
       ) do
    check_org(conn, org_id, project_id)
  end

  defp check_org(conn, org_id, project_id) do
    {org_id, _} = Integer.parse(org_id)
    {project_id, _} = Integer.parse(project_id)

    case OrgModel.get(org_id, project_id) do
      {:ok, org} ->
        assign(conn, :org, org)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
