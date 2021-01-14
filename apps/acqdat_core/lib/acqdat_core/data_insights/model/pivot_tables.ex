defmodule AcqdatCore.Model.DataInsights.PivotTables do
  alias AcqdatCore.DataInsights.Schema.PivotTables
  alias AcqdatCore.Model.Helper, as: ModelHelper
  alias AcqdatCore.Repo

  def create(params) do
    changeset = PivotTables.changeset(%PivotTables{}, params)
    Repo.insert(changeset)
  end

  def update(%PivotTables{} = pivot_table, params) do
    changeset = PivotTables.update_changeset(pivot_table, params)
    Repo.update(changeset)
  end

  def get_by_id(id) when is_integer(id) do
    case Repo.get(PivotTables, id) do
      nil ->
        {:error, "Pivot Table not found"}

      pivot_table ->
        {:ok, pivot_table}
    end
  end
end
