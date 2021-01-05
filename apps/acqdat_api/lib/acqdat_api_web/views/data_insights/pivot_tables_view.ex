defmodule AcqdatApiWeb.DataInsights.PivotTablesView do
  use AcqdatApiWeb, :view

  def render("pivot_table_data.json", %{pivot_table: pivot_table}) do
    %{
      pivot_table: pivot_table
    }
  end
end
