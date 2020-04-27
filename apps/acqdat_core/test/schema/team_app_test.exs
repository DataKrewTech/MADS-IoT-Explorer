defmodule AcqdatCore.Schema.TeamAppTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory

  alias AcqdatCore.Schema.TeamApp

  describe "changeset/2" do
    setup do
      team = insert(:team)
      app = insert(:app)

      [team: team, app: app]
    end

    test "returns a valid changeset", context do
      %{team: team, app: app} = context

      params = %{
        team_id: team.id,
        app_id: app.id
      }

      %{valid?: validity} = TeamApp.changeset(%TeamApp{}, params)
      assert validity
    end

    test "returns error changeset on empty params" do
      changeset = TeamApp.changeset(%TeamApp{}, %{})

      assert %{team_id: ["can't be blank"], app_id: ["can't be blank"]} == errors_on(changeset)
    end

    test "returns error when invalid team_id is inserted", context do
      %{app: app} = context

      assert {:error, changeset} =
               Repo.insert(TeamApp.changeset(%TeamApp{}, %{team_id: -1, app_id: app.id}))

      assert %{team_id: ["does not exist"]} == errors_on(changeset)
    end

    test "returns error when invalid app_id is inserted", context do
      %{team: team} = context

      assert {:error, changeset} =
               Repo.insert(TeamApp.changeset(%TeamApp{}, %{team_id: team.id, app_id: -1}))

      assert %{app_id: ["does not exist"]} == errors_on(changeset)
    end

    test "returns error when duplicate combination of team and app is inserted", context do
      %{team: team, app: app} = context
      Repo.insert(TeamApp.changeset(%TeamApp{}, %{team_id: team.id, app_id: app.id}))

      assert {:error, changeset} =
               Repo.insert(TeamApp.changeset(%TeamApp{}, %{team_id: team.id, app_id: app.id}))

      assert %{team_id: ["team_id_app_id is not unique"]} == errors_on(changeset)
    end
  end
end
