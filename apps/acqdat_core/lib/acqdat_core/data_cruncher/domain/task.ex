defmodule AcqdatCore.DataCruncher.Domain.Task do
  alias AcqdatCore.Repo
  alias AcqdatCore.DataCruncher.Domain.Workflow
  alias Virta.Core.Out
  alias Virta.{Node, EdgeData}
  alias AcqdatCore.DataCruncher.Model.{Dataloader, TempOutput}
  alias AcqdatCore.DataCruncher.Token

  def register_workflows(task) do
    task = task |> Repo.preload([:workflows])

    Enum.each(task.workflows, fn workflow ->
      graph = create_graph(workflow)
      Workflow.unregister(workflow.uuid)
      {:ok, _message} = Workflow.register(workflow.uuid, graph)
    end)

    {:ok, task}
  end

  def get_workflows() do
  end

  def get_workflows_in_mem() do
  end

  def execute_workflows(task) do
    Repo.transaction(fn ->
      Enum.each(task.workflows, fn workflow ->
        workflow
        |> execute_workflow()
        |> persist_output_to_temp_table(workflow)
      end)
    end)
  end

  def persist_output_to_temp_table({_request_id, output_data}, %{id: id} = workflow) do
    TempOutput.create(%{workflow_id: id, data: [output_data], format: "array"})
  end

  def execute_workflow(%{input_data: input_data, uuid: worflow_uuid} = workflow) do
    input_data
    |> generate_graph_data()
    |> Workflow.execute(worflow_uuid)
  end

  defp generate_graph_data(input_data) do
    # TODO: Needs to refactor and test it out for multiple input data and nodes
    nodes =
      Enum.reduce(input_data, %{}, fn data, acc ->
        stream_data = %Token{data: fetch_data_stream(data), data_type: :query_stream}

        Enum.reduce(data["nodes"], %{}, fn node, acc ->
          module = node |> fetch_function_module()
          node_from = module |> gen_node(node)

          res = [
            {
              UUID.uuid1(:hex),
              String.to_atom(node["i_port"]),
              stream_data
            }
          ]

          Map.put(acc, node_from, res)
        end)
      end)
  end

  defp fetch_data_stream(
         %{
           "sensor_id" => sensor_id,
           "parameter_id" => parameter_id,
           "start_date" => start_date,
           "end_date" => end_date
         } = data
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

  defp create_graph(%{graph: graph} = workflow) do
    new_graph = Graph.new(type: :directed)

    nodes =
      Enum.reduce(graph["edge_list"], [], fn edge, acc ->
        acc ++ [gen_edge(edge)]
      end)

    Graph.add_edges(new_graph, nodes)
  end

  defp gen_edge(%{"source_node" => source_node, "target_node" => target_node}) do
    source_module = source_node |> parse_module()
    target_module = target_node |> parse_module()

    node_from = source_module |> gen_node(source_node)
    node_to = target_module |> gen_node(target_node)
    {node_from, node_to, label: gen_edge_data(source_node)}
  end

  defp gen_node(module, %{"id" => id} = graph_node) do
    %Node{module: module, id: id}
  end

  defp gen_edge_data(%{"o_ports" => output_port}) do
    %EdgeData{from: String.to_atom(output_port), to: String.to_atom(output_port)}
  end

  defp parse_module(%{"type" => node_type} = graph_node) do
    case node_type do
      "function" ->
        graph_node
        |> fetch_function_module()

      "output" ->
        Out

      _ ->
        graph_node["module"]
    end
  end

  defp fetch_function_module(%{"module" => module}) do
    Module.concat(["AcqdatCore.DataCruncher.Functions.#{module}"])
  end

  defp parse_date(date) do
    date
    |> Timex.parse!("{YYYY}-{0M}-{0D}")
  end
end
