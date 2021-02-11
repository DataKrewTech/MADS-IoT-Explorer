defmodule AcqdatCore.Model.EntityManagement.Organisation do
  import Ecto.Query
  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.Model.EntityManagement.Project, as: ProjectModel
  alias AcqdatCore.Schema.RoleManagement.App
  alias AcqdatCore.Model.Helper, as: ModelHelper
  alias AcqdatCore.Repo

  def create(params) do
    changeset = Organisation.changeset(%Organisation{}, params)
    Repo.insert(changeset)
  end

  def update(org, params) do
    org = org |> Repo.preload([:apps])
    changeset = Organisation.update_changeset(org, params)
    Repo.update(changeset)
  end

  def get(id) when is_integer(id) do
    case Repo.get(Organisation, id) do
      nil ->
        {:error, "organisation not found"}

      org ->
        {:ok, org}
    end
  end

  def get_all(%{page_size: page_size, page_number: page_number}) do
    Organisation |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all(%{page_size: page_size, page_number: page_number}, preloads) do
    paginated_org_data =
      Organisation |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    org_data_with_preloads = paginated_org_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(org_data_with_preloads, paginated_org_data)
  end

  def get(params) when is_map(params) do
    case Repo.get_by(Organisation, params) do
      nil ->
        {:error, "organisation not found"}

      org ->
        {:ok, org}
    end
  end

  def get(id, project_id) when is_integer(id) do
    case Repo.get(Organisation, id) do
      nil ->
        {:error, "organisation not found"}

      org ->
        entities = ProjectModel.hierarchy_data(org.id, project_id)
        org = Map.put_new(org, :project_data, entities)
        {:ok, org}
    end
  end

  def fetch_hierarchy_by_all_projects(id) when is_integer(id) do
    case Repo.get(Organisation, id) |> Repo.preload([:projects]) do
      nil ->
        {:error, "organisation not found"}

      org ->
        project_data =
          Enum.reduce(org.projects, [], fn project, acc ->
            entities = ProjectModel.hierarchy_data(org.id, project.id)
            acc ++ entities
          end)

        org = Map.delete(org, :projects)
        org = Map.put_new(org, :project_data, project_data)
        {:ok, org}
    end
  end

  def get_by_id(id) when is_integer(id) do
    case Repo.get(Organisation, id) do
      nil ->
        {:error, "organisation not found"}

      org ->
        {:ok, org}
    end
  end

  def get_apps(_org) do
    # TODO: Need to filter by organisation, in future
    # org = org |> Repo.preload(:apps)
    # org.apps
    App |> order_by(:id) |> Repo.all()
  end
end
