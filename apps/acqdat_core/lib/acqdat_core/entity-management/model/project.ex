defmodule AcqdatCore.Model.EntityManagement.Project do
  import Ecto.Query
  alias AcqdatCore.Schema.EntityManagement.Project
  alias AcqdatCore.Schema.RoleManagement.User
  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.Model.EntityManagement.Asset, as: AssetModel
  alias AcqdatCore.Model.EntityManagement.Sensor, as: SensorModel
  alias AcqdatCore.Model.Helper, as: ModelHelper
  alias AcqdatCore.Repo

  def create(params) do
    changeset = Project.changeset(%Project{}, params)
    Repo.insert(changeset)
  end

  def hierarchy_data(org_id, project_id) do
    org_projects = fetch_projects(org_id, project_id)

    Enum.reduce(org_projects, [], fn project, acc ->
      entities = AssetModel.child_assets(project.id)
      sensors = SensorModel.get_all_by_parent_project(project.id)
      map_data = Map.put_new(project, :assets, entities)
      acc ++ [Map.put_new(map_data, :sensors, sensors)]
    end)
  end

  def get_by_id(id) when is_integer(id) do
    case Repo.get(Project, id) do
      nil ->
        {:error, "not found"}

      project ->
        {:ok, project}
    end
  end

  def update_version(%Project{} = project) do
    changeset = Project.update_changeset(project, %{version: Decimal.add(project.version, "0.1")})
    Repo.update(changeset)
  end

  def update(%Project{} = project, params) do
    changeset = Project.update_changeset(project, params)
    Repo.update(changeset)
  end

  defp fetch_projects(org_id, project_id) do
    query =
      from(project in Project,
        where: project.org_id == ^org_id and project.id == ^project_id
      )

    Repo.all(query)
  end

  def get_all(%{page_size: page_size, page_number: page_number}) do
    Project |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all(%{page_size: page_size, page_number: page_number, org_id: org_id}, preloads) do
    query =
      from(project in Project,
        join: org in Organisation,
        on: project.org_id == ^org_id and org.id == ^org_id
      )

    paginated_project_data =
      query |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    project_data_with_preloads = paginated_project_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(project_data_with_preloads, paginated_project_data)
  end

  def check_adminship(user_id) do
    user_details = Repo.get!(User, user_id) |> Repo.preload([:role])

    case user_details.role.name == "admin" do
      true -> true
      false -> false
    end
  end

  def delete(project) do
    changeset = Project.delete_changeset(project)

    case Repo.delete(changeset) do
      {:ok, project} ->
        project = project |> Repo.preload([:leads, :users])
        {:ok, project}

      {:error, project} ->
        {:error, project}
    end
  end
end
