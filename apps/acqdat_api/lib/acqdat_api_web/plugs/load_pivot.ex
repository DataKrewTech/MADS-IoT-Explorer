defmodule AcqdatApiWeb.Plug.LoadPivot do
  import Plug.Conn
  alias AcqdatCore.Model.DataInsights.PivotTables, as: PivotTables

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"pivot_table_id" => pivot_id}} = conn, _params) do
    check_pivot(conn, pivot_id)
  end

  def call(%{params: %{"id" => pivot_id}} = conn, _params) do
    check_pivot(conn, pivot_id)
  end

  defp check_pivot(conn, pivot_id) do
    case Integer.parse(pivot_id) do
      {pivot_id, _} ->
        case PivotTables.get_by_id(pivot_id) do
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
