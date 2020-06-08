defmodule AcqdatCore.DataCruncher.Domain.Workflow do
  @moduledoc """
  Module exposes functions to interact with a workflow.

  A workflow is essentially a graph with vertices and edges. A workflow is usually
  a part of a `task`. See `AcqdatCore.DataCruncher.Schema.Tasks`.
  """

  @doc """
  Registers a workflow.

  A workflow needs to be registered before it can be executed. On registering
  a dedicated supervision tree is created for the workflow under which all
  it's nodes are added.
  """
  def register() do

  end

  @doc """
  Executes a workflow.

  A workflow should be registered before it can be executed.
  """
  def execute() do

  end

  def add_edge() do

  end
end
