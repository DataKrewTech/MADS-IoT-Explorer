defmodule AcqdatApiWeb.DataCruncher.ComponentsView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.DataCruncher.ComponentsView

  def render("index.json", %{components: components}) do
    %{components: components}
  end
end
