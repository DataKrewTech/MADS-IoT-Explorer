defmodule AcqdatCore.Model.EntityManagement.Project do
  import Ecto.Query
  alias AcqdatCore.Schema.EntityManagement.Project
  alias AcqdatCore.Model.EntityManagement.Asset, as: AssetModel
  alias AcqdatCore.Repo

  def hierarchy_data(org_id) do
    org_projects = fetch_projects(org_id)

    Enum.reduce(org_projects, [], fn project, acc ->
      entities = AssetModel.child_assets(project.id)
      acc ++ [Map.put_new(project, :assets, entities)]
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

  defp fetch_projects(org_id) do
    query =
      from(project in Project,
        where: project.org_id == ^org_id
      )

    Repo.all(query)
  end
end
