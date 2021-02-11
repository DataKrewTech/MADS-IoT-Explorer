defmodule AcqdatCore.Model.DataInsights.Visualizations do
  alias AcqdatCore.DataInsights.Schema.Visualizations
  alias AcqdatCore.Model.Helper, as: ModelHelper
  alias AcqdatCore.Repo
  import Ecto.Query

  def create(params) do
    changeset = Visualizations.changeset(%Visualizations{}, params)
    Repo.insert(changeset)
  end

  def update(%Visualizations{} = visualization, params) do
    changeset = Visualizations.update_changeset(visualization, params)
    Repo.update(changeset)
  end

  def delete(visualization) do
    Repo.delete(visualization)
  end

  def get_by_id(id) when is_integer(id) do
    case Repo.get(Visualizations, id) do
      nil ->
        {:error, "Pivot Table not found"}

      visualization ->
        {:ok, visualization}
    end
  end

  def get_all(%{
        page_size: page_size,
        page_number: page_number,
        project_id: project_id,
        org_id: org_id,
        fact_tables_id: fact_tables_id
      }) do
    query =
      from(visualization in Visualizations,
        preload: [:creator],
        where:
          visualization.org_id == ^org_id and
            visualization.project_id == ^project_id and
            visualization.fact_table_id == ^fact_tables_id,
        order_by: visualization.name
      )

    query |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all_count_for_project(%{
        project_id: project_id,
        org_id: org_id
      }) do
    query =
      from(visualization in Visualizations,
        where:
          visualization.org_id == ^org_id and
            visualization.project_id == ^project_id,
        select: count(visualization.id)
      )

    Repo.one(query)
  end
end
