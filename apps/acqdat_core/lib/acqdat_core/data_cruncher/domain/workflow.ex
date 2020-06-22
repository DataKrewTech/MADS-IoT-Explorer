defmodule AcqdatCore.DataCruncher.Domain.Workflow do
  @moduledoc """
  Module exposes functions to interact with a workflow.

  A workflow is essentially a graph with vertices and edges. A workflow is usually
  a part of a `task`. See `AcqdatCore.DataCruncher.Schema.Tasks`.
  """
  alias Virta.{Registry, Executor}

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
end
