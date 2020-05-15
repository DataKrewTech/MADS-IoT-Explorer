defmodule AcqdatApiWeb.EntityManagement.OrganisationController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Model.EntityManagement.Organisation, as: OrgModel

  defdelegate get_apps(data), to: OrgModel

  plug :load_org when action in [:show, :get_apps]

  def show(conn, _params) do
    case conn.status do
      nil ->
        conn
        |> put_status(200)
        |> render("org.json", %{organisation: conn.assigns.org})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def get_apps(conn, _params) do
    case conn.status do
      nil ->
        org = conn.assigns.org

        with {:list, apps} <- {:list, get_apps(org)} do
          conn
          |> put_status(200)
          |> render("apps.json", %{apps: apps})
        else
          {:list, {:error, message}} ->
            send_error(conn, 400, message.error)
        end

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

    case OrgModel.get_by_id(org_id) do
      {:ok, org} ->
        assign(conn, :org, org)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
