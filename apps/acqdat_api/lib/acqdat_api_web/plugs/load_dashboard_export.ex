defmodule AcqdatApiWeb.Plug.LoadDashboardExport do
  import Plug.Conn
  alias AcqdatCore.Model.DashboardExport.DashboardExport, as: DashboardExportModel

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"dashboard_uuid" => dashboard_id}} = conn, _params) do
    check_dashboard(conn, dashboard_id)
  end

  defp check_dashboard(conn, dashboard_id) do
    case DashboardExportModel.get_by_uuid(dashboard_id) do
      {:ok, exported_dashboard} ->
        assign(conn, :exported_dashboard, exported_dashboard)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
