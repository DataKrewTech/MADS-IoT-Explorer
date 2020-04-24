defmodule AcqdatApi.Loader do
  alias AcqdatCore.Model.Organisation, as: OrgModel
  alias AcqdatCore.Model.User, as: UserModel
  import AcqdatApiWeb.Helpers
  import Plug.Conn

  def load_org(%{params: %{"org_id" => org_id}} = conn, params) do
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

  def load_user(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case UserModel.get(id) do
      {:ok, user} ->
        assign(conn, :user, user)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
