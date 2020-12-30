defmodule AcqdatApi.DataInsights.FactTables do
  alias AcqdatCore.Model.DataInsights.FactTables

  def create(org_id, %{name: project_name, id: project_id}) do
    res_name = :crypto.strong_rand_bytes(5) |> Base.url_encode64() |> binary_part(0, 5)
    fact_table_name = "#{project_name}_fact_table_#{res_name}"

    FactTables.create(%{name: fact_table_name, org_id: org_id, project_id: project_id})
  end
end
