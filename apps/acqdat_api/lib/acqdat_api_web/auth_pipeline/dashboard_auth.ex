defmodule AcqdatApiWeb.DashboardExportAuth do
  import Plug.Conn

  alias AcqdatCore.Model.DashboardExport.DashboardExport, as: DEModel

  @spec init(any) :: any
  def init(default), do: default

  def call(%{params: %{"dashboard_uuid" => dashboard_uuid}} = conn, _) do
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

    verify_dashboard(conn, DEModel.verify_uuid_and_token(dashboard_uuid, token))
  end

  defp verify_dashboard(conn, {:error, _}) do
    conn
    |> put_status(401)
  end

  defp verify_dashboard(conn, {:ok, exported_dashboard}) do
    assign(conn, :exported_dashboard, exported_dashboard)
  end
end
