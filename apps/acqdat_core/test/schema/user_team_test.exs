defmodule AcqdatCore.Schema.UserTeamTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory

  alias AcqdatCore.Schema.UserTeam

  describe "changeset/2" do
    setup do
      team = insert(:team)
      user = insert(:user)

      [team: team, user: user]
    end

    test "returns a valid changeset", context do
      %{team: team, user: user} = context

      params = %{
        team_id: team.id,
        user_id: user.id
      }

      %{valid?: validity} = UserTeam.changeset(%UserTeam{}, params)
      assert validity
    end

    test "returns error changeset on empty params" do
      changeset = UserTeam.changeset(%UserTeam{}, %{})

      assert %{team_id: ["can't be blank"], user_id: ["can't be blank"]} == errors_on(changeset)
    end

    test "returns error when invalid team_id is inserted", context do
      %{user: user} = context

      assert {:error, changeset} =
               Repo.insert(UserTeam.changeset(%UserTeam{}, %{team_id: -1, user_id: user.id}))

      assert %{team_id: ["does not exist"]} == errors_on(changeset)
    end

    test "returns error when invalid user_id is inserted", context do
      %{team: team} = context

      assert {:error, changeset} =
               Repo.insert(UserTeam.changeset(%UserTeam{}, %{team_id: team.id, user_id: -1}))

      assert %{user_id: ["does not exist"]} == errors_on(changeset)
    end

    test "returns error when duplicate combination of team and user is inserted", context do
      %{team: team, user: user} = context
      Repo.insert(UserTeam.changeset(%UserTeam{}, %{team_id: team.id, user_id: user.id}))

      assert {:error, changeset} =
               Repo.insert(UserTeam.changeset(%UserTeam{}, %{team_id: team.id, user_id: user.id}))

      assert %{team_id: ["team_id_user_id is not unique"]} == errors_on(changeset)
    end
  end
end
