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
end
