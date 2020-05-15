defmodule AcqdatCore.Schema.RoleManagement.UserAssetTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory

  alias AcqdatCore.Schema.RoleManagement.UserAsset

  describe "changeset/2" do
    setup do
      user = insert(:user)
      project = insert(:project)
      asset = insert(:asset)

      [user: user, asset: asset]
    end

    test "returns a valid changeset", context do
      %{user: user, asset: asset} = context

      params = %{
        user_id: user.id,
        asset_id: asset.id
      }

      %{valid?: validity} = UserAsset.changeset(%UserAsset{}, params)
      assert validity
    end

    test "returns error changeset on empty params" do
      changeset = UserAsset.changeset(%UserAsset{}, %{})

      assert %{user_id: ["can't be blank"], asset_id: ["can't be blank"]} == errors_on(changeset)
    end

    test "returns error when invalid user_id is inserted", context do
      %{asset: asset} = context

      assert {:error, changeset} =
               Repo.insert(UserAsset.changeset(%UserAsset{}, %{user_id: -1, asset_id: asset.id}))

      assert %{user_id: ["does not exist"]} == errors_on(changeset)
    end

    test "returns error when invalid asset_id is inserted", context do
      %{user: user} = context

      assert {:error, changeset} =
               Repo.insert(UserAsset.changeset(%UserAsset{}, %{user_id: user.id, asset_id: -1}))

      assert %{asset_id: ["does not exist"]} == errors_on(changeset)
    end

    test "returns error when duplicate combination of user and asset is inserted", context do
      %{user: user, asset: asset} = context
      Repo.insert(UserAsset.changeset(%UserAsset{}, %{user_id: user.id, asset_id: asset.id}))

      assert {:error, changeset} =
               Repo.insert(
                 UserAsset.changeset(%UserAsset{}, %{user_id: user.id, asset_id: asset.id})
               )

      assert %{user_id: ["has already been taken"]} == errors_on(changeset)
    end
  end
end
