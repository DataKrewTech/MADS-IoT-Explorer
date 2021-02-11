defmodule AcqdatApiWeb.Plug.LoadVisualizations do
  import Plug.Conn
  alias AcqdatCore.Model.DataInsights.Visualizations, as: Visualizations

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"pivot_table_id" => visual_id}} = conn, _params) do
    check_visualization(conn, visual_id)
  end

  def call(%{params: %{"id" => visual_id}} = conn, _params) do
    check_visualization(conn, visual_id)
  end

  defp check_visualization(conn, visual_id) do
    case Integer.parse(visual_id) do
      {visual_id, _} ->
        case Visualizations.get_by_id(visual_id) do
          {:ok, pivot} ->
            assign(conn, :pivot, pivot)

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
