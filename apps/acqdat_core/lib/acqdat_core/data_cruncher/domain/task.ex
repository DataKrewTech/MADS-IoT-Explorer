defmodule AcqdatCore.DataCruncher.Domain.Task do
  alias AcqdatCore.Repo
  alias AcqdatCore.DataCruncher.Domain.Workflow
  alias Virta.Core.Out
  alias Virta.{Node, EdgeData}

  def register_workflows(task) do
    task = task |> Repo.preload([:workflows])

    Enum.each(task.workflows, fn workflow ->
      graph = create_graph(workflow)
      Workflow.unregister(workflow.uuid)
      {:ok, _message} = Workflow.register(workflow.uuid, graph)
    end)

    {:ok, task}
  end

  # TODO: Needs to implement code as per future requirements
  def get_workflows() do
  end

  def get_workflows_in_mem() do
  end

  ############################# private functions ###########################

  defp create_graph(%{graph: graph} = _) do
    edge_list =
      graph
      |> Map.get("edge_list")
      |> Enum.map(&gen_edge/1)

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

  defp gen_node(module, %{"id" => id} = _) do
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
end
