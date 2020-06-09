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
    verify_project(
      attrs
      |> project_create_attrs()
      |> ProjectModel.create()
    )
  end

  defp project_create_attrs(
         %{
           lead_ids: lead_ids,
           user_ids: user_ids
         } = params
       ) do
    params = params_extraction(params)

    lead_ids = [-1 | lead_ids]
    user_ids = [-1 | user_ids]

    params
    |> Map.replace!(:lead_ids, lead_ids)
    |> Map.replace!(:user_ids, user_ids)
  end

  defp verify_project({:ok, project}) do
    project = project |> Repo.preload([:leads, :users])
    {:ok, project}
  end

  defp verify_project({:error, project}) do
    {:error, %{error: extract_changeset_error(project)}}
  end

  defp update_version(params, project) do
    Map.put_new(params, "version", Decimal.to_integer(project.version) + 1)
  end

  defp params_extraction(params) do
    Map.from_struct(params)
    |> Map.drop([:_id, :__meta__])
  end
end
