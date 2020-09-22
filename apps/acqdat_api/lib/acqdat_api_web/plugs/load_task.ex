defmodule AcqdatApiWeb.Plug.LoadTask do
  import Plug.Conn
  alias AcqdatCore.DataCruncher.Model.Task, as: TaskModel

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(%{params: %{"task_id" => task_id}} = conn, _params) do
    check_task(conn, task_id)
  end

  def call(%{params: %{"id" => task_id}} = conn, _params) do
    check_task(conn, task_id)
  end

  defp check_task(conn, task_id) do
    case Integer.parse(task_id) do
      {task_id, _} ->
        case TaskModel.get(task_id) do
          {:ok, task} ->
            assign(conn, :task, task)

          {:error, _message} ->
            conn
            |> put_status(404)
        end

      :error ->
        conn
        |> put_status(404)
    end
  end
end
