defmodule AcqdatApi.DataInsights.FactTableWorker do
  use GenServer
  alias AcqdatApi.DataInsights.FactTables
  alias AcqdatApi.DataInsights.FactTableServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def process(pid, params) do
    GenServer.cast(pid, {:register, params})
  end

  @impl GenServer
  def init(_args) do
    {:ok, nil}
  end

  @impl GenServer
  def handle_cast({:register, params}, _status) do
    output = execute_workflow(params)

    fact_table_id = elem(params, 0)

    AcqdatApiWeb.Endpoint.broadcast("project_fact_table:#{fact_table_id}", "out_put_res", %{
      data: output
    })

    FactTableServer.finished(self())

    {:noreply, output}
  end

  defp execute_workflow(
         {fact_table_id, parent_tree, root_node, entities_list, node_tracker} = params
       )
       when tuple_size(params) == 5 do
        FactTables.fetch_descendants(
          fact_table_id,
          parent_tree,
          root_node,
          entities_list,
          node_tracker
        )
  end

  defp execute_workflow({fact_table_id, entities_list, uniq_sensor_types} = params)
       when tuple_size(params) == 3 do
      FactTables.compute_sensors(
        fact_table_id,
        entities_list,
        uniq_sensor_types
      )
  end
end
