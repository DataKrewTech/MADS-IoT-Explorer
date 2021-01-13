defmodule AcqdatApi.DataInsights.FactTableGenWorker do
  use GenServer
  alias AcqdatCore.DataCruncher.Domain.Workflow
  alias AcqdatApi.DataInsights.Topology
  alias AcqdatCore.Repo

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def process(params) do
    GenServer.cast(__MODULE__, {:register, params})
  end

  def init(params) do
    {:ok, params}
  end

  def handle_cast({:register, params}, _status) do
    output =
      params
      |> execute_workflow()
      |> Task.await(:infinity)

    fact_table_id = elem(params, 0)

    AcqdatApiWeb.Endpoint.broadcast("project_fact_table:#{fact_table_id}", "out_put_res", %{
      data: output
    })

    {:noreply, output}
  end

  defp execute_workflow({fact_table_id, parent_tree, root_node, entities_list, node_tracker}) do
    Task.async(fn ->
      Topology.fetch_descendants(
        fact_table_id,
        parent_tree,
        root_node,
        entities_list,
        node_tracker
      )
    end)
  end
end
