defmodule AcqdatApiWeb.StreamLogic.WorkflowController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Validators.StreamLogic.Workflow
  import AcqdatApiWeb.Helpers
  alias AcqdatApi.StreamLogic

  plug AcqdatApiWeb.Plug.LoadStreamLogicWorkflow when
    action in [:update, :delete, :show]
  plug AcqdatApiWeb.Plug.LoadProject when action in [:create]

  def index(conn, params) do
    changeset = verify_index_params(params)
    with {:extract, {:ok, params}} <- {:extract, extract_changeset_data(changeset)} do
      workflows = StreamLogic.get_all(params)
      conn
      |> put_status(200)
      |> render("index.json", %{workflows: workflows})
    else
      {:extract, {:error, errors}} ->
        send_error(conn, 400, errors)
    end
  end

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_create_params(params)
        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
          {:create, {:ok, workflow}} <- {:create, StreamLogic.create(data)}
          do
            conn
            |> put_status(200)
            |> render("show.json", %{workflow: workflow})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message)
        end
      404 ->
        conn
        |> send_error(404, "Project not found")
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        workflow = conn.assigns.workflow
        with {:ok, workflow} <- StreamLogic.update(workflow, params) do
          conn
          |> put_status(200)
          |> render("show.json", %{workflow: workflow})
        else
          {:error, changeset} ->
            error =  extract_changeset_error(changeset)
            send_error(conn, 400, error)
        end
      404 ->
        conn
        |> send_error(404, conn.assigns.error_message)
    end
  end

  def show(conn, _params) do
    case conn.status do
      nil ->
        workflow = conn.assigns.workflow

        conn
        |> put_status(200)
        |> render("show.json", %{workflow: workflow})
      404 ->

        conn
        |> send_error(404, conn.assigns.error_message)
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        with {:ok, workflow} <- conn.assigns.workflow |> StreamLogic.delete() do
          conn
          |> put_status(200)
          |> render("show.json", %{workflow: workflow})
        else
          {:error, message} ->
          send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, conn.assigns.error_message)
    end
  end

end
