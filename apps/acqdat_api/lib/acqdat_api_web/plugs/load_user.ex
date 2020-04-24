defmodule AcqdatApiWeb.Plug.LoadUser do
  import Plug.Conn
  alias AcqdatCore.Model.User, as: UserModel

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"id" => id}} = conn, _params) do
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
