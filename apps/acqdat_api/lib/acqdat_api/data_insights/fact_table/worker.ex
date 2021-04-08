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

    fact_table_id = elem(params, 1)[:fact_table_id]

    AcqdatApiWeb.Endpoint.broadcast("project_fact_table:#{fact_table_id}", "out_put_res", %{
      data: output
    })

    FactTableServer.finished(self())

    {:noreply, output}
  end

  defp execute_workflow({type, params}) when type == "one_sensor_type" do
    FactTables.gen_comp_sensor_data(params)
  end

  defp execute_workflow({type, params}) when type == "one_asset_type" do
    FactTables.gen_comp_asset_data(params)
  end

  defp execute_workflow({type, params}) when type == "asset_metadatas" do
    FactTables.gen_comp_asset_metadata(params)
  end

  defp execute_workflow(
         {type,
          %{
            fact_table_id: fact_table_id,
            entities_list: entities_list,
            uniq_sensor_types: uniq_sensor_types
          }}
       )
       when type == "sensor_params" do
    FactTables.compute_sensors(
      fact_table_id,
      entities_list,
      uniq_sensor_types
    )
  end

  defp execute_workflow(
         {type,
          %{
            fact_table_id: fact_table_id,
            parent_tree: parent_tree,
            root_node: root_node,
            entities_list: entities_list,
            node_tracker: node_tracker
          }}
       )
       when type == "hybrid" do
    FactTables.fetch_descendants(
      fact_table_id,
      parent_tree,
      root_node,
      entities_list,
      node_tracker
    )
  end
end
