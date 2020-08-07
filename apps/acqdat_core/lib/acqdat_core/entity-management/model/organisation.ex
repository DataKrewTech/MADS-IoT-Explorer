defmodule AcqdatCore.Model.EntityManagement.Organisation do
  import Ecto.Query
  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.Model.EntityManagement.Project, as: ProjectModel
  alias AcqdatCore.Schema.RoleManagement.App
  alias AcqdatCore.Repo

  def get(id) when is_integer(id) do
    case Repo.get(Organisation, id) do
      nil ->
        {:error, "organisation not found"}

      org ->
        {:ok, org}
    end
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
