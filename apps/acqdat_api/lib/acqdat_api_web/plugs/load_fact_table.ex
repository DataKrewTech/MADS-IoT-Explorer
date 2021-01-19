defmodule AcqdatApiWeb.Plug.LoadFact do
  import Plug.Conn
  alias AcqdatCore.Model.DataInsights.FactTables

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"fact_table_id" => fact_id}} = conn, _params) do
    check_fact(conn, fact_id)
  end

  def call(%{params: %{"id" => fact_id}} = conn, _params) do
    check_fact(conn, fact_id)
  end

  defp check_fact(conn, fact_id) do
    case Integer.parse(fact_id) do
      {fact_id, _} ->
        case FactTables.get_by_id(fact_id) do
          {:ok, fact} ->
            assign(conn, :fact_table, fact)

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
