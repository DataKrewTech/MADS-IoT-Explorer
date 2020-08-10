defmodule AcqdatApiWeb.Plug.LoadOrg do
  import Plug.Conn
  alias AcqdatCore.Model.EntityManagement.Organisation, as: OrgModel

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"org_id" => org_id}} = conn, _params) do
    check_org(conn, org_id)
  end

  defp check_org(conn, org_id) do
    case Integer.parse(org_id) do
      {org_id, _} ->
        case OrgModel.get_by_id(org_id) do
          {:ok, org} ->
            assign(conn, :org, org)

          {:error, _message} ->
            conn
            |> put_status(404)
        end

      :error ->
        conn
        |> put_status(404)
    end
  end
end
