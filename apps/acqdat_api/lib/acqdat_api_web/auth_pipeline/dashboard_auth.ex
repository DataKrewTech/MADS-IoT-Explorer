defmodule AcqdatApiWeb.DashboardExportAuth do
  import Plug.Conn

  alias AcqdatCore.Model.DashboardExport.DashboardExport, as: DEModel

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"dashboard_uuid" => dashboard_uuid, "token" => token}} = conn, _params) do
    case DEModel.verify_uuid_and_token(dashboard_uuid, token) do
      {:error, message} ->
        conn
        |> put_status(401)

      {:ok, exported_dashboard} ->
        assign(conn, :exported_dashboard, exported_dashboard)
    end
  end
end
