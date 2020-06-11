defmodule AcqdatCore.DataCruncher.Domain.Task do
  alias AcqdatCore.Repo

  def register_workflows(task) do
    task = task |> Repo.preload([:workflows])
    {:ok, task}
  end

  def get_workflows() do
  end

  def get_workflows_in_mem() do
  end

  def execute_workflows() do
  end

  def execute_workflow() do
  end
end
