defmodule AcqdatApiWeb.EntityManagement.OrganisationView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.AppView
  alias AcqdatApiWeb.EntityManagement.OrganisationView
  alias AcqdatCore.Model.RoleManagement.User
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
      name: org.name,
      uuid: org.uuid
    }
  end

  def render("apps.json", %{apps: apps}) do
    %{
      apps: render_many(apps, AppView, "app.json")
    }
  end

  def render("index.json", %{organisation: organisation}) do
    %{
      organisations:
        render_many(organisation.entries, OrganisationView, "org_with_preloads.json"),
      page_number: organisation.page_number,
      page_size: organisation.page_size,
      total_entries: organisation.total_entries,
      total_pages: organisation.total_pages
    }
  end

  def render("org_with_preloads.json", %{organisation: organisation}) do
    admin_user = User.load_user(organisation.id)

    %{
      type: "Organisation",
      id: organisation.id,
      name: organisation.name,
      admin: render_many(admin_user, OrganisationView, "admin.json"),
      apps: render_many(organisation.apps, AppView, "app.json")
    }
  end

  def render("admin.json", %{organisation: user_details}) do
    %{
      id: user_details.id,
      email: user_details.email,
      first_name: user_details.first_name,
      last_name: user_details.last_name
    }
  end
end
