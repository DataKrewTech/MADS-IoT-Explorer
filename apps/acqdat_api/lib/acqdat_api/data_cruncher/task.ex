defmodule AcqdatApi.DataCruncher.Task do
  import AcqdatApiWeb.Helpers
  alias Ecto.Multi
  alias AcqdatCore.Repo
  alias AcqdatCore.DataCrunche.Model.Task, as: TaskModel
  alias AcqdatCore.DataCruncher.Domain.Task
  
  def create(params) do
    Multi.new()
    |> Multi.run(:create_task, fn _, _changes ->
      TaskModel.create(params)
    end)
    |> Multi.run(:register_workflows, fn _, %{create_task: task} ->
      Task.register_workflows(task)
    end)
    |> run_transaction()
  end

  defp run_transaction(multi_query) do
    result = Repo.transaction(multi_query)

    case result do
      {:ok, %{create_task: _create_task, register_workflows: _register_workflows}} ->
        {:ok, %{create_task: task}} = result
        {:ok, task}
      {:error, failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
  end
end