defmodule AcqdatApiWeb.Plug.LoadDashboard do
  import Plug.Conn
  alias AcqdatCore.Model.DashboardManagement.Dashboard, as: DashboardModel

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"dashboard_id" => dashboard_id}} = conn, _params) do
    check_dashboard(conn, dashboard_id)
  end

  def call(%{params: %{"id" => dashboard_id}} = conn, _params) do
    check_dashboard(conn, dashboard_id)
  end

  defp check_dashboard(conn, dashboard_id) do
    {dashboard_id, _} = Integer.parse(dashboard_id)

    case DashboardModel.get_by_id(dashboard_id) do
      {:ok, dashboard} ->
        assign(conn, :dashboard, dashboard)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
