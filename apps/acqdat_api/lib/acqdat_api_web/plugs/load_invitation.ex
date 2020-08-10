defmodule AcqdatApiWeb.Plug.LoadInvitation do
  import Plug.Conn
  alias AcqdatCore.Model.RoleManagement.Invitation, as: InvitationModel

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"id" => id}} = conn, _params) do
    case Integer.parse(id) do
      {id, _} ->
        case InvitationModel.get(id) do
          {:ok, invitation} ->
            assign(conn, :invitation, invitation)

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
