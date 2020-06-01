defmodule AcqdatApiWeb.EntityManagement.ProjectController do
  use AcqdatApiWeb, :controller
  alias AcqdatApi.EntityManagement.Project
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.EntityManagement.Project

  plug AcqdatApiWeb.Plug.LoadOrg
  @doc """
    This piece of code will be useful when we will implement Project role based listing
    #case ProjectModel.check_adminship(Guardian.Plug.current_resource(conn)) do
      #true ->
      # false ->
    #   conn
    #   |> send_error(404, "User is not admin!")
    #end
    """
  def index(conn, params) do
    changeset = verify_index_params(params)
    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, project} = {:list, Project.get_all(data, [])}
        conn
        |> put_status(200)
        |> render("show.json", project)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_project(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, project}} <- {:create, Project.create(data)} do
          conn
          |> put_status(200)
          |> render("show.json", %{project: project})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end
end
