defmodule AcqdatApiWeb.EntityManagement.ProjectController do
  use AcqdatApiWeb, :authorized_controller
  alias AcqdatApi.EntityManagement.Project
  alias AcqdatApi.Image
  alias AcqdatApi.ImageDeletion
  alias AcqdatCore.ElasticSearch
  alias AcqdatApiWeb.EntityManagement.ProjectErrorHelper
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.EntityManagement.Project

  # plug AcqdatApiWeb.ApiAccessAuth
  plug AcqdatApiWeb.Plug.LoadOrg

  plug AcqdatApiWeb.Plug.LoadProject
       when action in [:update, :delete, :show, :fetch_project_users]

  @doc """
  This piece of code will be useful when we will implement Project role based listing

  ## Examples

    case ProjectModel.check_adminship(Guardian.Plug.current_resource(conn)) do
    true ->
     false ->
       conn
       |> send_error(404, "User is not admin!")
    end
  """

  def search_projects(conn, params) do
    case conn.status do
      nil ->
        with {:ok, hits} <- ElasticSearch.search_projects(params) do
          conn |> put_status(200) |> render("hits.json", %{hits: hits})
        else
          {:error, message} ->
            conn
            |> send_error(404, ProjectErrorHelper.error_message(:elasticsearch, message))
        end

      404 ->
        conn
        |> send_error(404, ProjectErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, ProjectErrorHelper.error_message(:unauthorized))
    end
  end

  def index(conn, params) do
    case conn.status do
      nil ->
        with {:ok, hits} <- ElasticSearch.project_indexing(params) do
          conn |> put_status(200) |> render("hits.json", %{hits: hits})
        else
          {:error, message} ->
            conn
            |> send_error(404, ProjectErrorHelper.error_message(:elasticsearch, message))
        end

      404 ->
        conn
        |> send_error(404, ProjectErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, ProjectErrorHelper.error_message(:unauthorized))
    end
  end

  def archived(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, project} = {:list, Project.get_all_archived(data, [:leads, :users, :creator])}

        conn
        |> put_status(200)
        |> render("index.json", project)

      404 ->
        conn
        |> send_error(404, ProjectErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, ProjectErrorHelper.error_message(:unauthorized))
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{project: project}} = conn
        params = Map.put(params, "avatar", project.avatar)

        params = extract_image(conn, project, params)

        case Project.update(project, params) do
          {:ok, project} ->
            ElasticSearch.update_project("org", project, project.org_id)

            conn
            |> put_status(200)
            |> render("show.json", %{project: project})

          {:error, project} ->
            error = extract_changeset_error(project)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, ProjectErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, ProjectErrorHelper.error_message(:unauthorized))
    end
  end

  def create(conn, params) do
    case conn.status do
      nil ->
        params = add_avatar_to_params(conn, params)
        changeset = verify_project(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, project}} <- {:create, Project.create(data)} do
          Task.start_link(fn ->
            ElasticSearch.create_project("org", project, %{id: project.org_id})
          end)

          conn
          |> put_status(200)
          |> render("show.json", %{project: project})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message.error)
        end

      404 ->
        conn
        |> send_error(404, ProjectErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, ProjectErrorHelper.error_message(:unauthorized))
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        %{assigns: %{project: project}} = conn

        case Project.delete(project) do
          {:ok, project} ->
            if project.avatar != nil do
              ImageDeletion.delete_operation(project.avatar, "project")
            end

            ElasticSearch.delete_data("org", project)

            conn
            |> put_status(200)
            |> render("show.json", %{project: project})

          {:error, project} ->
            error = ProjectErrorHelper.error_message(project.errors)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, ProjectErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, ProjectErrorHelper.error_message(:unauthorized))
    end
  end

  def fetch_project_users(conn, _params) do
    case conn.status do
      nil ->
        %{assigns: %{project: project}} = conn

        {:list, users} = {:list, Project.get_all_users(project)}

        conn
        |> put_status(200)
        |> render("user_list.json", %{users: users})

      404 ->
        conn
        |> send_error(404, ProjectErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, ProjectErrorHelper.error_message(:unauthorized))
    end
  end

  defp add_avatar_to_params(conn, params) do
    params = Map.put(params, "avatar", "")

    case is_nil(params["image"]) do
      true ->
        params

      false ->
        add_image_url(conn, params)
    end
  end

  defp extract_image(conn, project, params) do
    case is_nil(params["image"]) do
      true ->
        params

      false ->
        if project.avatar != nil do
          ImageDeletion.delete_operation(project.avatar, "project")
        end

        add_image_url(conn, params)
    end
  end

  defp add_image_url(conn, %{"image" => image} = params) do
    with {:ok, image_name} <- Image.store({image, "project"}) do
      Map.replace!(params, "avatar", Image.url({image_name, "project"}))
    else
      {:error, error} -> send_error(conn, 400, error)
    end
  end
end
