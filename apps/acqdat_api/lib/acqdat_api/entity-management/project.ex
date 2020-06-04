defmodule AcqdatApi.EntityManagement.Project do
  alias AcqdatCore.Model.EntityManagement.Project, as: ProjectModel
  alias AcqdatCore.Repo
  import AcqdatApiWeb.Helpers

  defdelegate get_all(data, preloads), to: ProjectModel
  defdelegate delete(project), to: ProjectModel

  def update(project, params) do
    project = project |> Repo.preload([:leads, :users])
    params = update_version(params, project)
    ProjectModel.update(project, params)
  end

  def create(attrs) do
    verify_project(ProjectModel.create(project_create_attrs(attrs)))
  end

  defp project_create_attrs(%{
         name: name,
         description: description,
         avatar: avatar,
         metadata: metadata,
         location: location,
         archived: archived,
         version: version,
         start_date: start_date,
         org_id: org_id,
         creator_id: creator_id,
         lead_ids: lead_ids,
         user_ids: user_ids
       }) do
    lead_ids = [0 | lead_ids]
    user_ids = [0 | user_ids]

    %{
      name: name,
      description: description,
      avatar: avatar,
      metadata: metadata,
      location: location,
      archived: archived,
      version: version,
      start_date: start_date,
      org_id: org_id,
      creator_id: creator_id,
      lead_ids: lead_ids,
      user_ids: user_ids
    }
  end

  defp verify_project({:ok, project}) do
    project = project |> Repo.preload([:leads, :users])
    {:ok, project}
  end

  defp verify_project({:error, project}) do
    {:error, %{error: extract_changeset_error(project)}}
  end

  defp update_version(params, project) do
    Map.put_new(params, "version", project.version + 1)
  end
end
