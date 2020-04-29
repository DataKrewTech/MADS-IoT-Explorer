defmodule AcqdatCore.Model.TeamTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.Team, as: TeamModel

  describe "create/1" do
    setup do
      org = insert(:organisation)
      user = insert(:user)

      [org: org, user: user]
    end

    test "creates a team with supplied params", context do
      %{org: org, user: user} = context

      params = %{
        org_id: org.id,
        name: "Demo Team",
        assets: [1, 2],
        apps: [1, 2],
        users: [1, 2],
        creator_id: user.id
      }

      assert {:ok, _team} = TeamModel.create(params)
    end

    test "fails if org_id is not present", context do
      %{user: user} = context

      params = %{
        name: "Demo Team",
        creator_id: user.id
      }

      assert {:error, changeset} = TeamModel.create(params)
      assert %{org_id: ["can't be blank"]} == errors_on(changeset)
    end

    test "fails if name is not present", context do
      %{org: org, user: user} = context

      params = %{
        org_id: org.id,
        creator_id: user.id
      }

      assert {:error, changeset} = TeamModel.create(params)
      assert %{name: ["can't be blank"]} == errors_on(changeset)
    end

    test "fails if creator is not present", context do
      %{org: org} = context

      params = %{
        org_id: org.id,
        name: "Demo Team Test"
      }

      assert {:error, changeset} = TeamModel.create(params)
      assert %{creator_id: ["can't be blank"]} == errors_on(changeset)
    end
  end

  describe "update/2" do
    setup do
      user = insert(:user)
      team = insert(:team)

      [team: team, user: user]
    end

    test "updates the team's team lead", context do
      %{team: team, user: user} = context

      params = %{
        team_lead_id: user.id
      }

      refute team.team_lead_id == user.id

      assert {:ok, team} = TeamModel.update(team, params)
      assert team.team_lead_id == user.id
    end

    test "updates the team's description", context do
      %{team: team} = context

      params = %{
        description: "Updated Test Team description"
      }

      refute team.description == params[:description]

      assert {:ok, team} = TeamModel.update(team, params)
      assert team.description == params[:description]
    end

    test "updates the team's enable_tracking flag", context do
      %{team: team} = context

      params = %{
        enable_tracking: true
      }

      refute team.enable_tracking

      assert {:ok, team} = TeamModel.update(team, params)
      assert team.enable_tracking
    end
  end

  describe "update_assets/2" do
    setup do
      asset = insert(:asset)
      team = insert(:team)

      [team: team, asset: asset]
    end

    test "updates the team's assets", context do
      %{team: team, asset: asset} = context

      team = Repo.preload(team, :assets)
      assert length(team.assets) == 0

      assert {:ok, team} = TeamModel.update_assets(team, [asset.id])
      assert length(team.assets) == 1
    end
  end

  describe "update_apps/2" do
    setup do
      app = insert(:app)
      team = insert(:team)

      [team: team, app: app]
    end

    test "updates the team's apps", context do
      %{team: team, app: app} = context

      team = Repo.preload(team, :apps)
      assert length(team.apps) == 0

      assert {:ok, team} = TeamModel.update_apps(team, [app.id])
      assert length(team.apps) == 1
    end
  end

  describe "update_members/2" do
    setup do
      member = insert(:user)
      team = insert(:team)

      [team: team, member: member]
    end

    test "updates the team's members", context do
      %{team: team, member: member} = context

      team = Repo.preload(team, :users)
      assert length(team.users) == 0

      assert {:ok, team} = TeamModel.update_members(team, [member.id])
      assert length(team.users) == 1
    end
  end

  describe "get_all" do
    test "returns teams data" do
      team = insert(:team)

      params = %{page_size: 10, page_number: 1, org_id: team.org_id}
      result = TeamModel.get_all(params)

      assert not is_nil(result)
      assert result.total_entries == 1
    end

    test "returns error not found, if teams are not present" do
      params = %{page_size: 10, page_number: 1, org_id: 1}
      result = TeamModel.get_all(params)

      assert result.entries == []
      assert result.total_entries == 0
    end
  end
end
