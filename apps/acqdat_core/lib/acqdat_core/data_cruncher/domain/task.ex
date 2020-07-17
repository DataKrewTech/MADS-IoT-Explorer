defmodule AcqdatCore.DataCruncher.Domain.Task do
  alias AcqdatCore.Repo
  alias AcqdatCore.DataCruncher.Domain.Workflow
  alias Virta.Core.Out
  alias Virta.{Node, EdgeData}
  alias AcqdatCore.DataCruncher.Model.Dataloader
  alias AcqdatCore.DataCruncher.Schema.TempOutput
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

  ############################# private functions ###########################

  defp persist_output_to_temp_table({_request_id, output_data}, %{id: workflow_id} = workflow) do
    bulk_data = workflow_id |> generate_temp_output_bulk_data(output_data)
    Repo.insert_all(TempOutput, bulk_data)
  end

  defp generate_temp_output_bulk_data(workflow_id, output_data) do
    Enum.reduce(output_data, [], fn {key, val}, acc ->
      ele = [
        workflow_id: workflow_id,
        data: %{value: val},
        source_id: Atom.to_string(key),
        inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
        updated_at: DateTime.truncate(DateTime.utc_now(), :second)
      ]

      acc ++ [ele]
    end)
  end

  defp execute_workflow(%{input_data: input_data, uuid: worflow_uuid} = workflow) do
    input_data
    |> generate_graph_data()
    |> Workflow.execute(worflow_uuid)
  end

  defp generate_graph_data(input_data) do
    # TODO: Needs to refactor and test it out for multiple input data and nodes
    nodes =
      Enum.reduce(input_data, %{}, fn data, acc ->
        stream_data = %Token{data: fetch_data_stream(data), data_type: :query_stream}

        int_nodes =
          Enum.reduce(data["nodes"], %{}, fn node, acc1 ->
            module = node |> fetch_function_module()
            node_from = module |> gen_node(node)

            res = [
              {
                UUID.uuid1(:hex),
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
    edge_list =
      Enum.reduce(graph["edge_list"], [], fn edge, acc ->
        acc ++ [gen_edge(edge)]
      end)

    # NOTE: added outer edges for handling of multiple outputs in our graph
    out_node_id = UUID.uuid1(:hex)

    out_edge_list =
      Enum.reduce(graph["vertices"], [], fn vertex, acc1 ->
        if vertex["type"] == "output" do
          (acc1 || []) ++ [gen_out_edge(vertex, out_node_id)]
        end
      end)

    Graph.new(type: :directed)
    |> Graph.add_edges(edge_list ++ out_edge_list)
  end

  defp gen_out_edge(%{"id" => id, "module" => module, "outports" => output_ports}, out_node_id) do
    module_name = Module.concat([module])
    node_from = %Node{module: module_name, id: id}
    node_to = %Node{module: Out, id: out_node_id}
    output_port = output_ports |> List.first()

    {node_from, node_to,
     label: %EdgeData{from: String.to_atom(output_port), to: String.to_atom(id)}}
  end

  defp gen_edge(%{"source_node" => source_node, "target_node" => target_node}) do
    source_module = source_node |> parse_module()
    target_module = target_node |> parse_module()

    node_from = source_module |> gen_node(source_node)
    node_to = target_module |> gen_node(target_node)
    {node_from, node_to, label: gen_edge_data(source_node, target_node)}
  end

  defp gen_node(module, %{"id" => id} = graph_node) do
    %Node{module: module, id: id}
  end

  defp gen_edge_data(%{"outports" => output_port}, %{"inports" => input_port}) do
    %EdgeData{from: String.to_atom(output_port), to: String.to_atom(input_port)}
  end

  defp parse_module(%{"type" => node_type} = graph_node) do
    case node_type do
      "function" ->
        graph_node
        |> fetch_function_module()

      "output" ->
        graph_node
        |> fetch_function_module()

      _ ->
        graph_node["module"]
    end
  end

  defp fetch_function_module(%{"module" => module}) do
    Module.concat([module])
  end

  defp parse_date(date) do
    date
    |> Timex.parse!("{YYYY}-{0M}-{0D}")
  end
end
