defmodule AcqdatApiWeb.DashboardExportAuth do
  import Plug.Conn

  alias AcqdatCore.Model.DashboardExport.DashboardExport, as: DEModel

  @spec init(any) :: any
  def init(default), do: default

  def call(%{params: %{"dashboard_uuid" => dashboard_uuid}} = conn, _params) do
    token =
      case Map.has_key?(conn.params, "token") do
        true ->
          %{params: %{"token" => token}} = conn
          token

        false ->
          [token] =
            conn
            |> get_req_header("authorization")

          token |> String.trim("Bearer") |> String.trim(" ")
      end

    case DEModel.verify_uuid_and_token(dashboard_uuid, token) do
      {:error, message} ->
        conn
        |> put_status(401)

      {:ok, exported_dashboard} ->
        assign(conn, :exported_dashboard, exported_dashboard)
    end
  end
end
