defmodule AcqdatApi.EntityManagement.Project do
  alias AcqdatCore.Model.EntityManagement.Project, as: ProjectModel
  alias AcqdatCore.Repo
  import AcqdatApiWeb.Helpers

  defdelegate get_all(data, preloads), to: ProjectModel

  def create(attrs) do
    verify_project(ProjectModel.create(project_create_attrs(attrs)))
  end

  defp project_create_attrs(%{
    name: name,
    description: description,
    avatar: avatar ,
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
      avatar: avatar ,
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
    {:ok,
    %{
      id: project.id,
      uuid: project.uuid,
      slug: project.slug,
      name: project.name,
      description: project.description,
      avatar: project.avatar ,
      metadata: project.metadata,
      location: project.location,
      archived: project.archived,
      version: project.version,
      start_date: project.start_date,
      org_id: project.org_id,
      creator_id: project.creator_id,
      leads: project.leads,
      users: project.users
    }}
  end

  defp verify_project({:error, project}) do
    {:error, %{error: extract_changeset_error(project)}}
  end
end
