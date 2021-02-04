defmodule AcqdatCore.Schema.EntityManagement.AssetTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory

  alias AcqdatCore.Schema.EntityManagement.Asset

  describe "changeset/2" do
    setup do
      organisation = insert(:organisation)
      user = insert(:user)
      project = insert(:project)
      asset_type = insert(:asset_type)
      [organisation: organisation, project: project, user: user, asset_type: asset_type]
    end

    test "returns a valid changeset", context do
      %{organisation: organisation, project: project, user: user, asset_type: asset_type} =
        context

      params = %{
        name: "Bintan Factory",
        org_id: organisation.id,
        parent_id: organisation.id,
        project_id: project.id,
        asset_type_id: asset_type.id,
        creator_id: user.id
      }

      %{valid?: validity} = Asset.changeset(%Asset{}, params)
      assert validity
    end

    test "returns invalid if params empty" do
      %{valid?: validity} = changeset = Asset.changeset(%Asset{}, %{})
      refute validity

      assert %{
               asset_type_id: ["can't be blank"],
               org_id: ["can't be blank"],
               creator_id: ["can't be blank"],
               project_id: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "returns error if org assoc constraint not satisfied", %{
      user: user,
      project: project,
      asset_type: asset_type
    } do
      params = %{
        name: "Bintan Factory",
        org_id: -1,
        parent_id: -1,
        project_id: project.id,
        creator_id: user.id,
        asset_type_id: asset_type.id
      }

      changeset = Asset.changeset(%Asset{}, params)

      {:error, result_changeset} = Repo.insert(changeset)
      assert %{org: ["does not exist"]} == errors_on(result_changeset)
    end

    test "returns error if project assoc constraint not satisfied", %{
      organisation: organisation,
      asset_type: asset_type
    } do
      params = %{
        name: "Bintan Factory",
        org_id: organisation.id,
        parent_id: -1,
        asset_type_id: asset_type.id
      }

      changeset = Asset.changeset(%Asset{}, params)

      {:error, result_changeset} = Repo.insert(changeset)

      assert %{
               project_id: ["can't be blank"],
               creator_id: ["can't be blank"]
             } == errors_on(result_changeset)
    end

    test "returns error if asset with same name exists under a parent", %{
      organisation: organisation,
      project: project,
      user: user,
      asset_type: asset_type
    } do
      parent_asset = insert(:asset, org: organisation, project: project, asset_type: asset_type)

      child_asset_1 =
        insert(:asset,
          org: organisation,
          parent_id: parent_asset.id,
          project: project,
          asset_type: asset_type
        )

      params =
        :asset
        |> build(
          name: child_asset_1.name,
          org: organisation,
          parent_id: parent_asset.id,
          project: project,
          asset_type: asset_type,
          creator: user
        )
        |> Map.from_struct()
        |> Map.put(:org_id, organisation.id)
        |> Map.put(:project_id, project.id)
        |> Map.put(:asset_type_id, asset_type.id)
        |> Map.put(:creator_id, user.id)

      changeset = Asset.changeset(%Asset{}, params)
      {result, changeset} = Repo.insert(changeset)
      assert result == :error
      assert %{name: ["name already taken under this heirarchy"]} == errors_on(changeset)
    end

    # TODO: complete the test
    # test "returns error if no parent but asset with same name under same org", %{
    #   organisation: organisation
    # } do
    #   child_asset_1 = insert(:asset, org: organisation)
    # end

    # TODO: complete the test
    # test "allows insertion of asset with same name under different parents" do
    # end
  end
end
