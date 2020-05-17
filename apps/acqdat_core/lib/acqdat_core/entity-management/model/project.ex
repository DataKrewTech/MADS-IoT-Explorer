defmodule AcqdatCore.Model.EntityManagement.Project do
  import Ecto.Query
  alias AcqdatCore.Schema.EntityManagement.Project
  alias AcqdatCore.Model.EntityManagement.Asset, as: AssetModel
  alias AcqdatCore.Model.EntityManagement.Sensor, as: SensorModel
  alias AcqdatCore.Repo

  def hierarchy_data(org_id, project_id) do
    org_projects = fetch_projects(org_id, project_id)

    Enum.reduce(org_projects, [], fn project, acc ->
      entities = AssetModel.child_assets(project.id)
      sensors = SensorModel.get_by_project(project.id)
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
    changeset = Project.update_changeset(project, %{version: project.version + 1})
    Repo.update(changeset)
  end

  defp fetch_projects(org_id, project_id) do
    query =
      from(project in Project,
        where: project.org_id == ^org_id and project.id == ^project_id
      )

    Repo.all(query)
  end
end
