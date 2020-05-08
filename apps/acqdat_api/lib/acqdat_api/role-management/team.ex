defmodule AcqdatApi.RoleManagement.Team do
  alias AcqdatCore.Model.RoleManagement.Team, as: TeamModel
  import AcqdatApiWeb.Helpers

  def get(team_id) do
    TeamModel.get(team_id)
  end

  def create(attrs, current_user) do
    %{
      name: name,
      description: description,
      team_lead_id: team_lead_id,
      enable_tracking: enable_tracking,
      org_id: org_id,
      assets: assets,
      apps: apps,
      members: members
    } = attrs

    asset_ids = Enum.map(assets || [], & &1["id"])
    app_ids = Enum.map(apps || [], & &1["id"])
    member_ids = Enum.map(members || [], & &1["id"])

    team_details =
      %{}
      |> Map.put(:name, name)
      |> Map.put(:description, description)
      |> Map.put(:org_id, org_id)
      |> Map.put(:team_lead_id, team_lead_id)
      |> Map.put(:enable_tracking, enable_tracking)
      |> Map.put(:assets, asset_ids)
      |> Map.put(:apps, app_ids)
      |> Map.put(:users, member_ids)
      |> Map.put(:creator_id, current_user.id)

    verify_team(TeamModel.create(team_details))
  end

  def update_assets(team, %{assets: assets}) do
    asset_ids = Enum.map(assets, & &1["id"])

    verify_team(TeamModel.update_assets(team, asset_ids))
  end

  def update_apps(team, %{apps: apps}) do
    app_ids = Enum.map(apps, & &1["id"])

    verify_team(TeamModel.update_apps(team, app_ids))
  end

  def update_members(team, %{members: members}) do
    member_ids = Enum.map(members, & &1["id"])

    verify_team(TeamModel.update_members(team, member_ids))
  end

  def update(team, attrs) do
    %{
      team_lead_id: team_lead_id,
      enable_tracking: enable_tracking,
      description: description
    } = attrs

    verify_team(
      TeamModel.update(team, %{
        team_lead_id: team_lead_id,
        enable_tracking: enable_tracking,
        description: description
      })
    )
  end

  defp verify_team({:ok, team}) do
    {:ok, team}
  end

  defp verify_team({:error, team}) do
    {:error, %{error: extract_changeset_error(team)}}
  end
end
