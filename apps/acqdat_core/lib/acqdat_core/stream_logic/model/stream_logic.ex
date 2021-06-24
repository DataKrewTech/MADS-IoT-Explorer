defmodule AcqdatCore.StreamLogic.Model do
  import Ecto.Query
  alias AcqdatCore.Repo
  alias AcqdatCore.StreamLogic.Schema.Workflow
  alias AcqdatCore.Model.EntityManagement.Project
  alias AcqdatCore.StreamLogic.Model.ConsumerGroup
  alias Ecto.Multi
  alias Virta.Node
  alias Virta.Registry
  alias Virta.EdgeData

  @doc """
  Creates a workflow and returns it.

  Whenever a workflow is created the following set of events also happen:
  - It is registered under the `Virta.Registry` which is used for initiating
    the workflow to receive messages.
  - Each workflow also registers itself as a consumer(subscriber) to the project
    specific telemetry topic. The topics and data are stored in Kafka. At present
    each workflow acts as a consumer group with just one consumer.
  """
  def create(params) do
    changeset = Workflow.changeset(%Workflow{}, params)
    Multi.new()
    |> Multi.insert(:insert_chain, changeset)
    |> Multi.run(:register_chain, fn _repo, %{insert_chain: chain} ->
      register_workflow(chain)
    end)
    |> Multi.run(:start_consumer, fn _repo, %{insert_chain: chain} ->
      subscribe_workflow(chain)
    end)
    |> persist()
  end

  @doc """
  Updates a workflow with the `params`.

  ## Note
  In case the workflow digraph or the name is updated it will be re-registered.
  In case the worklow enabled is changed to false, the workflow would be
  de-registered and it's subscription from the queue will also be removed.
  """
  def update(workflow, params) do
    changeset = Workflow.update_changeset(workflow, params)
    # add code for updating the registered workflow
    # add code for checking the registration status
    # add code for handling the subscription
    Repo.update(changeset)
  end

  def get(id)  when is_integer(id) do
    case Repo.get(Workflow, id) do
      nil ->
        {:error, "not found"}
      workflow ->
        {:ok, workflow}
    end
  end

  def get(map)  when is_map(map) do
    case Repo.get_by(Workflow, map) do
      nil ->
        {:error, "not found"}
      workflow ->
        {:ok, workflow}
    end
  end

  def get_all(%{
        page_size: page_size,
        page_number: page_number,
        org_id: org_id,
        project_id: project_id
      }) do
    query =
      from(workflow in Workflow,
        where: workflow.org_id == ^org_id and workflow.project_id == ^project_id,
        order_by: workflow.id
      )

    query |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def delete(workflow) do
    try do
      Repo.delete(workflow)
    rescue
      Ecto.StaleEntryError ->
        {:error, "not found"}
      _ ->
        {:error, "Unexpected error"}
    end
  end

  ################## private functions #########################

  defp persist(multi) do
    case Repo.transaction(multi) do
      {:error, _failed_operation, failed_value, _changes} ->
        {:error, failed_value}
      {:ok, %{insert_chain: workflow}} ->
        {:ok, workflow}
      end
  end

  defp register_workflow(workflow) do
    name = "workflow" <> workflow.uuid
    graph = prepare_graph(workflow.digraph)
    Registry.register(name, graph)
  end

  defp subscribe_workflow(workflow) do
    {:ok, project} = workflow.project_id |> Project.get()
    topic = "project-#{project.uuid}-telemetry"
    name = "workflow_consumer" <> workflow.uuid
    ConsumerGroup.start_consumer_group(name, topic)
  end

  defp prepare_graph(digraph) do
    %{edge_list: edge_list, vertices: vertices} = digraph
    mapped_vertices = Enum.reduce( vertices, %{}, fn vertex, acc ->
      node = create_node_struct(vertex)
      Map.put(acc, vertex.uuid, node)
    end)

    Enum.reduce(edge_list, Graph.new(type: :directed), fn edge, acc ->
      source = mapped_vertices[edge.source_id]
      target = mapped_vertices[edge.target_id]
      acc
      |> Graph.add_edge(
        source,
        target,
        label: struct(EdgeData, edge.label)
        )
      end)
  end

  defp create_node_struct(vertex) do
    params = vertex |> Map.from_struct() |> Map.put(:id, vertex.uuid)
    struct(Node, params)
  end

end
