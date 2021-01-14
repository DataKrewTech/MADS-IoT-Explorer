defmodule AcqdatApiWeb.DataInsights.PivotTablesView do
  use AcqdatApiWeb, :view

  def render("pivot_table_data.json", %{pivot_table: pivot_table}) do
    %{
      pivot_table: pivot_table
    }
  end

  def render("create.json", %{pivot_table: pivot_table}) do
    %{
      id: pivot_table.id,
      name: pivot_table.name
    }
  end
end
