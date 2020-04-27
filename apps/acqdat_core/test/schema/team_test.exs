defmodule AcqdatCore.Schema.TeamTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory

  alias AcqdatCore.Schema.Team

  describe "changeset/2" do
    setup do
      org = insert(:organisation)
      user = insert(:user)

      [org: org, user: user]
    end

    test "returns error changeset on empty params" do
      changeset = Team.changeset(%Team{}, %{})

      assert %{
               name: ["can't be blank"],
               org_id: ["can't be blank"],
               creator_id: ["can't be blank"]
             } == errors_on(changeset)
    end

    test "returns error when duplicate name is used", context do
      %{org: org, user: user} = context
      team = insert(:team)

      params = %{
        org_id: org.id,
        name: team.name,
        assets: [1, 2],
        apps: [1, 2],
        users: [1, 2],
        creator_id: user.id
      }

      changeset = Team.changeset(%Team{}, params)

      {:error, changeset} = Repo.insert(changeset)

      assert %{name: ["has already been taken"]} == errors_on(changeset)
    end

    test "returns a valid changeset", context do
      %{org: org, user: user} = context

      params = %{
        org_id: org.id,
        name: "Demo Team",
        assets: [1, 2],
        apps: [1, 2],
        users: [1, 2],
        creator_id: user.id
      }

      %{valid?: validity} = Team.changeset(%Team{}, params)
      assert validity
    end
  end

  describe "update_assets/2" do
    setup do
      team = insert(:team)

      [team: team]
    end

    test "updates assets of the team", context do
      asset = insert(:asset)
      %{team: team} = context

      %{valid?: validity} = Team.update_assets(team, [asset])
      assert validity
    end
  end

  describe "update_apps/2" do
    setup do
      team = insert(:team)

      [team: team]
    end

    test "updates apps of the team", context do
      app = insert(:app)
      %{team: team} = context

      %{valid?: validity} = Team.update_apps(team, [app])
      assert validity
    end
  end

  describe "update_members/2" do
    setup do
      team = insert(:team)

      [team: team]
    end

    test "updates members of the team", context do
      member = insert(:user)
      %{team: team} = context

      %{valid?: validity} = Team.update_members(team, [member])
      assert validity
    end
  end
end
