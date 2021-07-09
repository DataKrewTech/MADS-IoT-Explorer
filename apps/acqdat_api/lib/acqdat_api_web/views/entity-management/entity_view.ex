defmodule AcqdatApiWeb.EntityManagement.EntityView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.EntityManagement.ProjectView

  def render("organisation_tree.json", %{org: org}) do
    %{
      type: "Organisation",
      id: org.id,
      name: org.name,
      entities: render_many(org.project_data, ProjectView, "project.json")
    }
  end
end
