defmodule AcqdatApiWeb.DataCruncher.EntityController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Model.EntityManagement.Organisation, as: OrgModel
  alias AcqdatApiWeb.DataCruncher.EntityErrorHelper

  plug AcqdatApiWeb.Plug.LoadCurrentUser
  plug AcqdatApiWeb.Plug.LoadOrg
  plug :put_view, AcqdatApiWeb.EntityManagement.EntityView when action in [:fetch_all_hierarchy]

  @secret_key_base Application.get_env(:acqdat_api, AcqdatApiWeb.Endpoint)[:secret_key_base]

  def fetch_token(conn, _params) do
    case conn.status do
      nil ->
        token =
          Phoenix.Token.sign(conn, @secret_key_base, %{
            user_id: conn.assigns.current_user.id,
            org_id: conn.assigns.org.id
          })

        conn
        |> put_status(200)
        |> render("valid_token.json", token: token)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")

      401 ->
        conn
        |> send_error(401, "Unauthorized")
    end
  end

  def fetch_all_hierarchy(conn, %{"org_id" => org_id}) do
    case conn.status do
      nil ->
        {org_id, _} = Integer.parse(org_id)

        case OrgModel.fetch_hierarchy_by_all_projects(org_id) do
          {:ok, org} ->
            conn
            |> put_status(200)
            |> render("organisation_tree.json", %{org: org})

          {:error, _message} ->
            conn
            |> send_error(404, EntityErrorHelper.error_message(:resource_not_found))
        end

      404 ->
        conn
        |> send_error(404, EntityErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, EntityErrorHelper.error_message(:unauthorized))
    end
  end
end
