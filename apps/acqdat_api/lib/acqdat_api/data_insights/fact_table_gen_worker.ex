defmodule AcqdatApi.DataInsights.FactTableGenWorker do
  use GenServer
  alias AcqdatApi.DataInsights.FactTables

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

  defp execute_workflow(
         {fact_table_id, parent_tree, root_node, entities_list, node_tracker} = params
       )
       when tuple_size(params) == 5 do
    Task.async(fn ->
      FactTables.fetch_descendants(
        fact_table_id,
        parent_tree,
        root_node,
        entities_list,
        node_tracker
      )
    end)
  end

  defp execute_workflow({fact_table_id, entities_list, uniq_sensor_types} = params)
       when tuple_size(params) == 3 do
    Task.async(fn ->
      FactTables.compute_sensors(
        fact_table_id,
        entities_list,
        uniq_sensor_types
      )
    end)
  end
end
