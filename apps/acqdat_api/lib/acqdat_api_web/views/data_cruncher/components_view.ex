defmodule AcqdatApiWeb.DataCruncher.ComponentsView do
  use AcqdatApiWeb, :view

  def render("index.json", %{components: components}) do
    %{components: components}
  end
end
