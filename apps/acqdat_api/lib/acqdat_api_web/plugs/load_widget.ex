defmodule AcqdatApiWeb.Plug.LoadWidget do
  import Plug.Conn
  alias AcqdatCore.Model.Widgets.Widget, as: WidgetModel

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"widget_id" => widget_id}} = conn, _params) do
    check_widget(conn, widget_id)
  end

  def call(%{params: %{"id" => widget_id}} = conn, _params) do
    check_widget(conn, widget_id)
  end

  defp check_widget(conn, widget_id) do
    {widget_id, _} = Integer.parse(widget_id)

    case WidgetModel.get(widget_id) do
      {:ok, widget} ->
        assign(conn, :widget, widget)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
