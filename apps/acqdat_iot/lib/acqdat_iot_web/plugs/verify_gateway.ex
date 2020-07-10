defmodule AcqdatIotWeb.Plugs.VerifyGateway do
  import Plug.Conn
  alias AcqdatCore.Model.IotManager.Gateway, as: GModel

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"gateway_id" => gateway_id}} = conn, _params) do
    check_gateway(conn, gateway_id)
  end

  defp check_gateway(conn, gateway_id) do
    {gateway_id, _} = Integer.parse(gateway_id)

    case GModel.get_by_id(gateway_id) do
      {:ok, gateway} ->
        [token] = Plug.Conn.get_req_header(conn, "authorization")
        ["Bearer", access_token] = String.split(token, " ")

        case access_token == gateway.access_token do
          true ->
            assign(conn, :gateway, gateway)

          false ->
            conn
            |> put_status(404)
        end

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
