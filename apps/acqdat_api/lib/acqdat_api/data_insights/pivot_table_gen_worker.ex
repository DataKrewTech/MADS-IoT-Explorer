defmodule AcqdatApi.DataInsights.PivotTableGenWorker do
  use GenServer
  alias AcqdatApi.DataInsights.PivotTables

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def process(params) do
    GenServer.cast(__MODULE__, {:register, params})
  end

  def init(params) do
    {:ok, params}
  end

  def handle_cast({:register, params}, _) do
    output =
      params
      |> execute()
      |> Task.await(:infinity)

    pivot_table = elem(params, 0)

    AcqdatApiWeb.Endpoint.broadcast(
      "project_pivot_table:#{pivot_table.id}",
      "out_put_res_pivot",
      %{
        data: output
      }
    )

    {:noreply, output}
  end

  defp execute({pivot_table, params}) do
    Task.async(fn ->
      PivotTables.gen_pivot_table(
        params,
        pivot_table
      )
    end)
  end
end
