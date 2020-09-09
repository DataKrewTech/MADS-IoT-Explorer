defmodule AcqdatApi.DataCruncher.Task do
  alias Ecto.Multi
  alias AcqdatCore.Repo
  alias AcqdatCore.DataCrunche.Model.Task, as: TaskModel
  alias AcqdatCore.DataCruncher.Domain.Task
  alias AcqdatApi.DataCruncher.TaskExecuteWorker

  defdelegate get_all(data), to: TaskModel
  defdelegate get(id), to: TaskModel
  defdelegate delete(task), to: TaskModel

  def create(%{"id" => id, "action" => action} = params)
      when action == "execute" or action == "register" do
    verify_task(TaskModel.get(id), params)
  end

  def create(params) do
    Multi.new()
    |> Multi.run(:create_task, fn _, _changes ->
      TaskModel.create(params)
    end)
    |> Multi.run(:register_workflows, fn _, %{create_task: task} ->
      task
      |> Repo.preload(workflows: :temp_output)
      |> Task.register_workflows()
    end)
    |> run_transaction()
  end

  defp validate_res(:ok, task) do
    {:ok, task |> Repo.preload(workflows: :temp_output)}
  end

  defp validate_res(:error, task) do
    {:error, "something went wrong!"}
  end

  defp verify_task({:ok, task}, %{"action" => action}) when action == "execute" do
    task
    |> TaskExecuteWorker.process()
    |> validate_res(task)
  end

  defp verify_task({:ok, task}, %{"action" => action} = params) when action == "register" do
    Multi.new()
    |> Multi.run(:update_task, fn _, _changes ->
      TaskModel.update(task, params)
    end)
    |> Multi.run(:register_workflows, fn _, %{update_task: task} ->
      Task.register_workflows(task)
    end)
    |> run_transaction()
  end

  defp verify_task({:error, message}, _action) do
    {:error, message}
  end

  defp run_transaction(multi_query) do
    result = Repo.transaction(multi_query)

    case result do
      {:ok, %{create_task: _create_task, register_workflows: _register_workflows}} ->
        {:ok, %{register_workflows: task}} = result
        {:ok, task}

      {:ok, %{update_task: _create_task, register_workflows: _register_workflows}} ->
        {:ok, %{update_task: task}} = result
        {:ok, task}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        {:error, failed_value}
    end
  end
end
