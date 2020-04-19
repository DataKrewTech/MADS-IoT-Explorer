defmodule AcqdatApiWeb.RoleView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.RoleView

  def render("role.json", %{role: role}) do
    %{
      description: role.description,
      id: role.id,
      name: role.name
    }
  end

  def render("index.json", sensor) do
    %{
      sensors: render_many(sensor.entries, RoleView, "role.json")
    }
  end
end
