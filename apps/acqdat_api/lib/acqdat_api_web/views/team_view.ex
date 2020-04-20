defmodule AcqdatApiWeb.TeamView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.TeamView

  def render("team_details.json", %{team: team}) do
    %{
      id: team.id,
      name: team.name,
      enable_tracking: team.enable_tracking
    }
  end

  def render("index.json", team) do
    %{
      teams: render_many(team.entries, TeamView, "team_with_preloads.json"),
      page_number: team.page_number,
      page_size: team.page_size,
      total_entries: team.total_entries,
      total_pages: team.total_pages
    }
  end

  def render("team_with_preloads.json", %{team: team}) do
    %{
      id: team.id,
      name: team.name,
      enable_tracking: team.enable_tracking,
      members: render_many(team.users, TeamView, "member_details.json"),
      assets: render_many(team.assets, TeamView, "asset_details.json"),
      apps: render_many(team.apps, TeamView, "app_details.json")
    }
  end

  def render("member_details.json", %{team: member}) do
    %{
      id: member.id,
      email: member.email,
      first_name: member.first_name,
      last_name: member.last_name
    }
  end

  def render("asset_details.json", %{team: asset}) do
    %{
      id: asset.id,
      name: asset.name,
      properties: asset.properties
    }
  end

  def render("app_details.json", %{team: app}) do
    %{
      id: app.id,
      name: app.name,
      description: app.description
    }
  end
end
