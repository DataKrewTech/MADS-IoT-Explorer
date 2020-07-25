defmodule AcqdatApi.DataCruncher.TaskExecuteWorker do
  use GenServer
  alias AcqdatCore.DataCruncher.Domain.Workflow

  def start_link(_) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  def process(task) do
    GenServer.cast(__MODULE__, {:register, task})
  end

  def init(params) do
    {:ok, params}
  end

  def handle_cast({:register, task}, _status) do
    tasks =
      Enum.map(task.workflows, fn workflow ->
        workflow
        |> execute_workflow()
      end)
      |> Enum.map(fn task -> Task.await(task) end)

    AcqdatApiWeb.Endpoint.broadcast("tasks:#{task.id}", "out_put_res", %{data: task})
    {:noreply, task}
  end

  defp execute_workflow(workflow) do
    Task.async(Workflow.gen_and_exec(workflow))
  end
end
