defmodule AcqdatApiWeb.EntityManagement.OrganisationView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.AppView
  alias AcqdatApiWeb.EntityManagement.ProjectView

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

  def render("apps.json", %{apps: apps}) do
    %{
      apps: render_many(apps, AppView, "app.json")
    }
  end
end
