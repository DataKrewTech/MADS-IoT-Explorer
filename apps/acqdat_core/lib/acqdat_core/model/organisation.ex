defmodule AcqdatCore.Model.Organisation do
  alias AcqdatCore.Schema.Organisation
  alias AcqdatCore.Model.Project, as: ProjectModel
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
end

