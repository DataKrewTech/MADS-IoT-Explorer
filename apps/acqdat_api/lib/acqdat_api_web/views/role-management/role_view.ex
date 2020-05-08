defmodule AcqdatApiWeb.RoleManagement.RoleView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.RoleManagement.RoleView

  def render("role.json", %{role: role}) do
    %{
      description: role.description,
      id: role.id,
      name: role.name
    }
  end

  def render("index.json", role) do
    %{
      roles: render_many(role.entries, RoleView, "role.json")
    }
  end
end
