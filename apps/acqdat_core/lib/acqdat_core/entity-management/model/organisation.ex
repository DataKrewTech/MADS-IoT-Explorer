defmodule AcqdatCore.Model.EntityManagement.Organisation do
  import Ecto.Query
  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.Model.EntityManagement.Project, as: ProjectModel
  alias AcqdatCore.Schema.RoleManagement.App
  alias AcqdatCore.Repo

  def get(id) when is_integer(id) do
    case Repo.get(Organisation, id) do
      nil ->
        {:error, "not found"}

      org ->
        entities = ProjectModel.hierarchy_data(org.id)

        org = Map.put_new(org, :project_data, entities)
        {:ok, org}
    end
  end

  def get_by_id(id) when is_integer(id) do
    case Repo.get(Organisation, id) do
      nil ->
        {:error, "not found"}

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
