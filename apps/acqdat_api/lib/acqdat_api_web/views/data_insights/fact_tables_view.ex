defmodule AcqdatApiWeb.DataInsights.FactTablesView do
  use AcqdatApiWeb, :view

  def render("create.json", %{fact_table: fact_table}) do
    %{
      id: fact_table.id,
      name: fact_table.name
    }
  end
end
