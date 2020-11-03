defmodule AcqdatCore.Model.DataInsights.FactTables do
  alias AcqdatCore.DataInsights.Schema.FactTables
  alias AcqdatCore.Model.Helper, as: ModelHelper
  alias AcqdatCore.Repo

  def create(params) do
    changeset = FactTables.changeset(%FactTables{}, params)
    Repo.insert(changeset)
  end

  def update(%FactTables{} = fact_table, params) do
    changeset = FactTables.update_changeset(fact_table, params)
    Repo.update(changeset)
  end
end
