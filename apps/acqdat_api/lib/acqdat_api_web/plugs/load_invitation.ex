defmodule AcqdatApiWeb.Plug.LoadInvitation do
  import Plug.Conn
  alias AcqdatCore.Model.Invitation, as: InvitationModel

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case InvitationModel.get(id) do
      {:ok, invitation} ->
        assign(conn, :invitation, invitation)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
