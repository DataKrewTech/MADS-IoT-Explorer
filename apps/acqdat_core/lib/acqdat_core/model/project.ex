defmodule AcqdatCore.Model.Project do
  import Ecto.Query
  alias AcqdatCore.Schema.Project
  alias AcqdatCore.Model.Asset, as: AssetModel
  alias AcqdatCore.Repo

  def hierarchy_data(org_id) do
    org_projects = fetch_projects(org_id)

    org_projects =
      Enum.reduce(org_projects, [], fn project, acc ->
        entities = AssetModel.child_assets(project.id)
        acc = acc ++ [Map.put_new(project, :assets, entities)]
      end)
  end

  defp fetch_projects(org_id) do
    query =
      from(project in Project,
        where: project.org_id == ^org_id
      )

    Repo.all(query)
  end
end