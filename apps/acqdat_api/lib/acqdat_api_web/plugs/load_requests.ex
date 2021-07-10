defmodule AcqdatApiWeb.Plug.LoadRequests do
  @moduledoc """
  Plug to verify if request exist before taking action like updation, deletion or just showing it.
  """
  import Plug.Conn
  alias AcqdatCore.Model.RoleManagement.Requests

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"id" => request_id}} = conn, _params) do
    check_request(conn, request_id)
  end

  def call(%{params: %{"request_id" => request_id}} = conn, _params) do
    check_request(conn, request_id)
  end

  defp check_request(conn, request_id) do
    {request_id, _} = Integer.parse(request_id)

    case Requests.get(request_id) do
      {:ok, request} ->
        assign(conn, :request, request)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
