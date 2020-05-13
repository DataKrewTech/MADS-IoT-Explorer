defmodule AcqdatApiWeb.OrganisationView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.{AssetView, ProjectView}

  def render("organisation_tree.json", %{org: org}) do
    %{
      type: "Organisation",
      id: org.id,
      name: org.name,
      entities: render_many(org.project_data, ProjectView, "project.json")
    }
  end

  def render("org.json", %{organisation: org}) do
    %{
      type: "Organisation",
      id: org.id,
      name: org.name
    }
  end
end
