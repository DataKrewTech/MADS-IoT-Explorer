defmodule AcqdatApiWeb.DataInsights.FactTablesView do
  use AcqdatApiWeb, :view

  def render("create.json", %{fact_table: fact_table}) do
    %{
      id: fact_table.id,
      name: fact_table.name
    }
  end

  def render("fact_table_data.json", %{fact_table: fact_table}) do
    %{
      fact_table: fact_table
    }
  end
end
