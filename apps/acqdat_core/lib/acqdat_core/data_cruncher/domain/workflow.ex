defmodule AcqdatCore.DataCruncher.Domain.Workflow do
  @moduledoc """
  Module exposes functions to interact with a workflow.

  A workflow is essentially a graph with vertices and edges. A workflow is usually
  a part of a `task`. See `AcqdatCore.DataCruncher.Schema.Tasks`.
  """
  alias Virta.{Registry, Executor}
  alias Virta.Node
  alias AcqdatCore.DataCruncher.Token
  alias AcqdatCore.DataCruncher.Model.Dataloader
  alias AcqdatCore.Repo
  alias AcqdatCore.DataCruncher.Schema.TempOutput
  alias AcqdatCore.DataCruncher.Model.TempOutput, as: TempOutputModel

  @doc """
  Registers a workflow.

  A workflow needs to be registered before it can be executed. On registering
  a dedicated supervision tree is created for the workflow under which all
  it's nodes are added.
  """
  def register(workflow_id, graph) do
    Registry.register(workflow_id, graph)
  end

  def unregister(workflow_id) do
    Registry.unregister(workflow_id)
  end

  @doc """
  Executes a workflow.

  **Note**
  A workflow should be registered before it can be executed.
  """
  def execute(data, workflow_id) do
    Executor.call(workflow_id, data)
  end

  def gen_and_exec(%{uuid: workflow_uuid} = workflow) do
    workflow
    |> generate_graph_data()
    |> execute(workflow_uuid)
    |> update_temp_table()
  end

  ############################# private functions ###########################

  defp update_temp_table({_, output_data}) do
    # TODO: Need to refactor this code to bulk update
    Enum.each(output_data, fn {key, val} ->
      params = %{source_id: Atom.to_string(key)}
      temp_output = Repo.get(TempOutput, val)

      if temp_output do
        TempOutputModel.update(temp_output, params)
      end
    end)
  end

  defp generate_graph_data(%{input_data: input_data, id: workflow_id} = _) do
    # TODO: Needs to refactor and test it out for multiple input data and nodes
    Enum.reduce(input_data, %{}, fn data, acc ->
      stream_data = %Token{data: fetch_data_stream(data), data_type: :query_stream}

      int_nodes =
        Enum.reduce(data["nodes"], %{}, fn node, acc1 ->
          module = node |> fetch_function_module()
          node_from = module |> gen_node(node)

          res = [
            {
              workflow_id,
              String.to_atom(node["inports"]),
              stream_data
            }
          ]

          Map.put(acc1, node_from, res)
        end)

      Map.merge(acc, int_nodes)
    end)
  end

  defp fetch_data_stream(
         %{
           "sensor_id" => sensor_id,
           "parameter_id" => parameter_id,
           "start_date" => start_date,
           "end_date" => end_date
         } = _
       ) do
    date_to = parse_date(end_date)
    date_from = parse_date(start_date)

    Dataloader.load_stream(:pds, %{
      sensor_id: sensor_id,
      param_uuid: parameter_id,
      date_from: date_from,
      date_to: date_to
    })
  end

  defp gen_node(module, %{"id" => id} = _) do
    %Node{module: module, id: id}
  end

  defp fetch_function_module(%{"module" => module}) do
    Module.concat([module])
  end

  defp parse_date(date) do
    date
    |> Timex.parse!("{YYYY}-{0M}-{0D}")
  end
end
