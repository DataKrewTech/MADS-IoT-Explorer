defmodule AcqdatApiWeb.DataCruncher.TasksController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  alias AcqdatApi.DataCruncher.Task

  plug AcqdatApiWeb.Plug.LoadCurrentUser when action in [:create]
  plug AcqdatApiWeb.Plug.LoadOrg when action in [:create]

  def create(conn, params) do
    case conn.status do
      nil ->
        with {:create, {:ok, task}} <-
               {:create, Task.create(params) } do
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
end
