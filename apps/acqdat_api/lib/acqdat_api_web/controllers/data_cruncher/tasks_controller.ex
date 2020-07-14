defmodule AcqdatApiWeb.DataCruncher.TasksController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.DataCruncher.Tasks
  alias AcqdatApi.DataCruncher.Task

  plug AcqdatApiWeb.Plug.LoadCurrentUser
  plug AcqdatApiWeb.Plug.LoadOrg

  def create(conn, params) do
    case conn.status do
      nil ->
        with {:create, {:ok, task}} <-
               {:create, Task.create(params)} do
          conn
          |> put_status(200)
          |> render("task.json", %{task: task})
        else
          {:create, {:error, error}} ->
            send_error(conn, 400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, tasks} = {:list, Task.get_all(data)}

        conn
        |> put_status(200)
        |> render("index.json", tasks)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def show(conn, %{"id" => task_id}) do
    case conn.status do
      nil ->
        {task_id, _} = Integer.parse(task_id)

        case Task.get(task_id) do
          {:error, message} ->
            send_error(conn, 400, message)

          {:ok, task} ->
            conn
            |> put_status(200)
            |> render("task.json", %{task: task})
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end
end
