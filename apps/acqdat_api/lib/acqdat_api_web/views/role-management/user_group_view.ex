defmodule AcqdatApiWeb.RoleManagement.UserGroupView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.RoleManagement.UserGroupView

  def render("user_group.json", %{group: group}) do
    %{
      id: group.id,
      name: group.name,
      org_id: group.org_id,
      policies: render_many(group.policies, UserGroupView, "policies.json")
    }
  end

  def render("user_group_index.json", %{user_group: user_group}) do
    %{
      id: user_group.id,
      name: user_group.name,
      org_id: user_group.org_id,
      policies: render_many(user_group.policies, UserGroupView, "policies.json")
    }
  end

  def render("user_group_index_policies.json", %{user_group: user_group}) do
    %{
      id: user_group.id,
      policies: render_many(user_group.policies, UserGroupView, "policies.json")
    }
  end

  def render("policies.json", %{user_group: user_group}) do
    %{
      action: user_group.action,
      app: user_group.app,
      feature: user_group.feature
    }
  end

  def render("index.json", group) do
    %{
      groups: render_many(group.entries, UserGroupView, "user_group_index.json"),
      page_number: group.page_number,
      page_size: group.page_size,
      total_entries: group.total_entries,
      total_pages: group.total_pages
    }
  end

  def render("index_policies.json", group) do
    %{
      groups: render_many(group.entries, UserGroupView, "user_group_index_policies.json"),
      page_number: group.page_number,
      page_size: group.page_size,
      total_entries: group.total_entries,
      total_pages: group.total_pages
    }
  end
end
