defmodule AcqdatCore.Schema.RoleManagement.TeamAssetTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory

  alias AcqdatCore.Schema.RoleManagement.TeamAsset

  describe "changeset/2" do
    setup do
      team = insert(:team)
      asset = insert(:asset)

      [team: team, asset: asset]
    end

    test "returns a valid changeset", context do
      %{team: team, asset: asset} = context

      params = %{
        team_id: team.id,
        asset_id: asset.id
      }

      %{valid?: validity} = TeamAsset.changeset(%TeamAsset{}, params)
      assert validity
    end

    test "returns error changeset on empty params" do
      changeset = TeamAsset.changeset(%TeamAsset{}, %{})

      assert %{team_id: ["can't be blank"], asset_id: ["can't be blank"]} == errors_on(changeset)
    end

    test "returns error when invalid team_id is inserted", context do
      %{asset: asset} = context

      assert {:error, changeset} =
               Repo.insert(TeamAsset.changeset(%TeamAsset{}, %{team_id: -1, asset_id: asset.id}))

      assert %{team_id: ["does not exist"]} == errors_on(changeset)
    end

    test "returns error when invalid asset_id is inserted", context do
      %{team: team} = context

      assert {:error, changeset} =
               Repo.insert(TeamAsset.changeset(%TeamAsset{}, %{team_id: team.id, asset_id: -1}))

      assert %{asset_id: ["does not exist"]} == errors_on(changeset)
    end

    test "returns error when duplicate combination of team and asset is inserted", context do
      %{team: team, asset: asset} = context
      Repo.insert(TeamAsset.changeset(%TeamAsset{}, %{team_id: team.id, asset_id: asset.id}))

      assert {:error, changeset} =
               Repo.insert(
                 TeamAsset.changeset(%TeamAsset{}, %{team_id: team.id, asset_id: asset.id})
               )

      assert %{team_id: ["team_id_asset_id is not unique"]} == errors_on(changeset)
    end
  end
end
