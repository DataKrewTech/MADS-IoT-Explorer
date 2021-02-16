defmodule AcqdatCore.Model.DataInsights.FactTables do
  alias AcqdatCore.DataInsights.Schema.FactTables
  alias AcqdatCore.Model.Helper, as: ModelHelper
  alias AcqdatCore.Repo
  import Ecto.Query

  def create(params) do
    changeset = FactTables.changeset(%FactTables{}, params)
    Repo.insert(changeset)
  end

  def update(%FactTables{} = fact_table, params) do
    changeset = FactTables.update_changeset(fact_table, params)
    Repo.update(changeset)
  end

  def delete(fact_table) do
    Repo.delete(fact_table)
  end

  def get_fact_table_headers(fact_table_id) do
    query =
      "SELECT column_name FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'fact_table_#{
        fact_table_id
      }'"

    Ecto.Adapters.SQL.query!(Repo, query, [], timeout: :infinity)
  end

  def get_by_id(id) do
    case Repo.get(FactTables, id) do
      nil ->
        {:error, "FactTables not found"}

      fact_table ->
        {:ok, fact_table}
    end
  end

  def get_all(%{
        page_size: page_size,
        page_number: page_number,
        project_id: project_id,
        org_id: org_id
      }) do
    query =
      from(fact_table in FactTables,
        left_join: pivot in assoc(fact_table, :pivot_tables),
        preload: [:creator],
        group_by: fact_table.id,
        where: fact_table.org_id == ^org_id and fact_table.project_id == ^project_id,
        order_by: fact_table.name,
        select_merge: %{pivot_count: count(pivot.id)}
      )

    query |> Repo.paginate(page: page_number, page_size: page_size)
  end
end
