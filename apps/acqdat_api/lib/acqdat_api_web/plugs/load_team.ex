defmodule AcqdatApiWeb.Plug.LoadTeam do
  import Plug.Conn
  alias AcqdatApi.Team

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case Team.get(id) do
      {:ok, team} ->
        assign(conn, :team, team)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
