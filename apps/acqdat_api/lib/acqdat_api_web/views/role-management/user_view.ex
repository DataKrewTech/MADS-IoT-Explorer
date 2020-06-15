defmodule AcqdatApiWeb.RoleManagement.UserView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.RoleManagement.UserView
  alias AcqdatApiWeb.RoleManagement.RoleView
  alias AcqdatApiWeb.EntityManagement.OrganisationView
  alias AcqdatCore.Schema.RoleManagement.Role
  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.Repo
  alias AcqdatApiWeb.RoleManagement.RoleView

  def render("user_details.json", %{user_details: user_details}) do
    %{
      id: user_details.id,
      email: user_details.email,
      first_name: user_details.first_name,
      last_name: user_details.last_name,
      image: user_details.avatar,
      is_invited: user_details.is_invited,
      role_id: user_details.role_id,
      user_setting: render_one(user_details.user_setting, UserView, "user_setting.json"),
      role: render_one(preload_role(user_details.role_id), RoleView, "role.json"),
      org:
        render_one(
          preload_org(user_details.org_id),
          OrganisationView,
          "org.json"
        )
    }
  end

  def render("user_details_without_user_setting.json", %{user_details: user_details}) do
    %{
      id: user_details.id,
      email: user_details.email,
      first_name: user_details.first_name,
      last_name: user_details.last_name,
      is_invited: user_details.is_invited,
      role_id: user_details.role_id,
      role: render_one(preload_role(user_details.role_id), RoleView, "role.json"),
      org:
        render_one(
          preload_org(user_details.org_id),
          OrganisationView,
          "org.json"
        )
    }
  end

  def render("user_index.json", %{user: user_details}) do
    %{
      id: user_details.id,
      email: user_details.email,
      first_name: user_details.first_name,
      last_name: user_details.last_name,
      image: user_details.avatar,
      is_invited: user_details.is_invited,
      role_id: user_details.role_id,
      user_setting: render_one(user_details.user_setting, UserView, "user_setting.json"),
      role: render_one(preload_role(user_details.role_id), RoleView, "role.json"),
      org:
        render_one(
          preload_org(user_details.org_id),
          OrganisationView,
          "org.json"
        )
    }
  end

  def render("index.json", user_details) do
    %{
      users: render_many(user_details.entries, UserView, "user_index.json"),
      page_number: user_details.page_number,
      page_size: user_details.page_size,
      total_entries: user_details.total_entries,
      total_pages: user_details.total_pages
    }
  end

  def render("user_setting.json", setting) do
    %{
      user_setting_id: setting.user.id,
      visual_settings: Map.from_struct(setting.user.visual_settings),
      data_settings: Map.from_struct(setting.user.data_settings)
    }
  end

  def render("hits.json", %{hits: hits}) do
    %{
      users: render_many(hits.hits, UserView, "source.json")
    }
  end

  def render("index_hits.json", user) do
    %{
      users: render_many(user.entries, UserView, "source.json"),
      page_number: user.page_number,
      page_size: user.page_size,
      total_entries: user.total_entries,
      total_pages: user.total_pages
    }
  end

  def render("source.json", %{user: hits}) do
    %{
      id: hits.id,
      first_name: hits.first_name,
      last_name: hits.last_name,
      email: hits.email,
      org_id: hits.org_id,
      role_id: hits.role_id,
      role: render_one(hits.role, RoleView, "role.json"),
      org:
        render_one(
          hits.org,
          OrganisationView,
          "org.json"
        )
    }
  end

  def render("user_assets.json", %{user: user}) do
    %{
      id: user.id,
      email: user.email,
      assets: render_many(user.assets, UserView, "asset.json")
    }
  end

  def render("asset.json", asset) do
    %{
      type: "Asset",
      id: asset.user.id,
      name: asset.user.name,
      properties: asset.user.properties
    }
  end

  def render("user_apps.json", %{user: user}) do
    %{
      id: user.id,
      email: user.email,
      apps: render_many(user.apps, UserView, "app.json")
    }
  end

  def render("app.json", app) do
    %{
      id: app.user.id,
      name: app.user.name,
      description: app.user.description
    }
  end

  defp preload_role(id) do
    Map.from_struct(Repo.get(Role, id))
  end

  defp preload_org(id) do
    Map.from_struct(Repo.get(Organisation, id))
  end
end
