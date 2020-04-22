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

  describe "get_all/1" do
    test "returns a particular sensor" do
      insert(:team)

      params = %{page_size: 10, page_number: 1}
      result = TeamModel.get_all(params)

      assert not is_nil(result)
      assert result.total_entries == 1
    end

    test "returns error not found, if sensor is not present" do
      params = %{page_size: 10, page_number: 1}
      result = TeamModel.get_all(params)

      assert result.entries == []
      assert result.total_entries == 0
    end
  end
end
