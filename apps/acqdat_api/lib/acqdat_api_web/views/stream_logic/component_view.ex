defmodule AcqdatApiWeb.StreamLogic.ComponentsView do
  use AcqdatApiWeb, :view

  def render("components.json", %{components: components_list}) do
    %{
      components: render_many(components_list, __MODULE__, "component.json", as: :component)
    }
  end

  def render("component.json", %{component: component}) do
    %{
      inports: component.inports,
      outports: component.outports,
      properties: component.properties,
      category: component.category,
      info: component.info,
      display_name: component.display_name,
      module: component.module
    }
  end
end
