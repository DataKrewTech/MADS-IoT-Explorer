defmodule AcqdatApi.DataInsights.FactTables do
  alias AcqdatCore.Model.DataInsights.FactTables
  alias AcqdatCore.Repo

  def create(org_id, %{name: project_name, id: project_id}) do
    res_name = :crypto.strong_rand_bytes(5) |> Base.url_encode64() |> binary_part(0, 5)
    fact_table_name = "#{project_name}_fact_table_#{res_name}"

    FactTables.create(%{name: fact_table_name, org_id: org_id, project_id: project_id})
  end

  def fetch_name_by_id(%{"id" => id, "name" => name}) do
    fact_table_name = "fact_table_#{id}"

    qry = """
      select distinct "#{name}" from #{fact_table_name}
      where "#{name}" is not null and length("#{name}") > 0
      order by 1
    """

    res = Ecto.Adapters.SQL.query!(Repo, qry, [])
    %{data: List.flatten(res.rows)}
  end
end
