defmodule AcqdatApi.Team do
  alias AcqdatCore.Model.Team, as: TeamModel
  import AcqdatApiWeb.Helpers

  def create(attrs, current_user) do
    %{
      name: name,
      team_lead_id: team_lead_id,
      enable_tracking: enable_tracking,
      org_id: org_id,
      assets: assets,
      apps: apps,
      users: users
    } = attrs

    asset_ids = Enum.map(assets || [], & &1["id"])
    app_ids = Enum.map(apps || [], & &1["id"])
    user_ids = Enum.map(users || [], & &1["id"])

    team_details =
      %{}
      |> Map.put(:name, name)
      |> Map.put(:org_id, org_id)
      |> Map.put(:team_lead_id, team_lead_id)
      |> Map.put(:enable_tracking, enable_tracking)
      |> Map.put(:assets, asset_ids)
      |> Map.put(:apps, app_ids)
      |> Map.put(:users, user_ids)
      |> Map.put(:creator_id, current_user.id)

    verify_team(TeamModel.create(team_details))
  end

  defp verify_team({:ok, team}) do
    {:ok,
     %{
       id: team.id,
       name: team.name,
       enable_tracking: team.enable_tracking
     }}
  end

  defp verify_team({:error, team}) do
    {:error, %{error: extract_changeset_error(team)}}
  end
end
