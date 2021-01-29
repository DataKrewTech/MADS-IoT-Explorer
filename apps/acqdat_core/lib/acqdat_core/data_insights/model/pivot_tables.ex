defmodule AcqdatCore.Model.DataInsights.PivotTables do
  alias AcqdatCore.DataInsights.Schema.PivotTables
  alias AcqdatCore.Model.Helper, as: ModelHelper
  alias AcqdatCore.Repo
  import Ecto.Query

  def create(params) do
    changeset = PivotTables.changeset(%PivotTables{}, params)
    Repo.insert(changeset)
  end

  def update(%PivotTables{} = pivot_table, params) do
    changeset = PivotTables.update_changeset(pivot_table, params)
    Repo.update(changeset)
  end

  def delete(pivot_table) do
    Repo.delete(pivot_table)
  end

  def get_by_id(id) when is_integer(id) do
    case Repo.get(PivotTables, id) do
      nil ->
        {:error, "Pivot Table not found"}

      pivot_table ->
        {:ok, pivot_table}
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
      from(pivot_table in PivotTables,
        preload: [:creator],
        where:
          pivot_table.org_id == ^org_id and
            pivot_table.project_id == ^project_id and
            pivot_table.fact_table_id == ^fact_tables_id,
        order_by: pivot_table.name
      )

    query |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all_count_for_project(%{
        project_id: project_id,
        org_id: org_id
      }) do
    query =
      from(pivot_table in PivotTables,
        where:
          pivot_table.org_id == ^org_id and
            pivot_table.project_id == ^project_id,
        select: count(pivot_table.id)
      )

    Repo.one(query)
  end
end
