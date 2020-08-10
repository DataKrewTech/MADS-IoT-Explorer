defmodule AcqdatApiWeb.Plug.LoadGateway do
  import Plug.Conn
  alias AcqdatCore.Model.IotManager.Gateway, as: GModel

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"id" => gateway_id}} = conn, _params) do
    check_gateway(conn, gateway_id)
  end

  def call(%{params: %{"gateway_id" => gateway_id}} = conn, _params) do
    check_gateway(conn, gateway_id)
  end

  defp check_gateway(conn, gateway_id) do
    case Integer.parse(gateway_id) do
      {gateway_id, _} ->
        case GModel.get_by_id(gateway_id) do
          {:ok, gateway} ->
            assign(conn, :gateway, gateway)

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
