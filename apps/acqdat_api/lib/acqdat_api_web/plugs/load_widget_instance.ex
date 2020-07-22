defmodule AcqdatApiWeb.Plug.LoadWidgetInstance do
  import Plug.Conn
  alias AcqdatCore.Model.DashboardManagement.WidgetInstance, as: WidgetModel

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"widget_instance_id" => widget_id}} = conn, _params) do
    check_widget(conn, widget_id)
  end

  def call(%{params: %{"id" => widget_id}} = conn, _params) do
    check_widget(conn, widget_id)
  end

  defp check_widget(conn, widget_id) do
    {widget_id, _} = Integer.parse(widget_id)

    case WidgetModel.get_by_id(widget_id) do
      {:ok, widget} ->
        assign(conn, :widget_instance, widget)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
