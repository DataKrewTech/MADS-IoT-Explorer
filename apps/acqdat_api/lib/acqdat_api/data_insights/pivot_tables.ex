defmodule AcqdatApi.DataInsights.PivotTables do
  alias AcqdatCore.Model.DataInsights.PivotTables

  def create(org_id, fact_tables_id, %{name: project_name, id: project_id}) do
    res_name = :crypto.strong_rand_bytes(5) |> Base.url_encode64() |> binary_part(0, 5)
    pivot_table_name = "#{project_name}_pivot_table_#{fact_tables_id}_#{res_name}"

    PivotTables.create(%{
      name: pivot_table_name,
      org_id: org_id,
      project_id: project_id,
      fact_table_id: fact_tables_id
    })
  end
end
