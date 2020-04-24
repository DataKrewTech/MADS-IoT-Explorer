defmodule AcqdatApiWeb.OrganisationController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Model.Organisation, as: OrgModel

  plug :load_org when action in [:show]

  def show(conn, _params) do
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

  defp load_org(%{params: %{"id" => org_id}} = conn, _params) do
    check_org(conn, org_id)
  end

  defp check_org(conn, org_id) do
    {org_id, _} = Integer.parse(org_id)

    case OrgModel.get(org_id) do
      {:ok, org} ->
        assign(conn, :org, org)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
