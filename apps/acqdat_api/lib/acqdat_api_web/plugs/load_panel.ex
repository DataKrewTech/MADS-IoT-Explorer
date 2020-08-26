defmodule AcqdatApiWeb.Plug.LoadPanel do
  import Plug.Conn
  alias AcqdatCore.Model.DashboardManagement.Panel, as: PanelModel

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"panel_id" => panel_id}} = conn, _params) do
    check_panel(conn, panel_id)
  end

  def call(%{params: %{"id" => panel_id}} = conn, _params) do
    check_panel(conn, panel_id)
  end

  defp check_panel(conn, panel_id) do
    case Integer.parse(panel_id) do
      {panel_id, _} ->
        case PanelModel.get_by_id(panel_id) do
          {:ok, panel} ->
            assign(conn, :panel, panel)

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
