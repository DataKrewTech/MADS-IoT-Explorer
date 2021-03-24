defmodule AcqdatCore.Model.EntityManagement.AssetTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.EntityManagement.Asset
  alias AcqdatCore.Schema.EntityManagement.Asset, as: AssetSchema
  alias AcqdatCore.Repo

  describe "get_by_id/1" do
    test "returns a asset" do
      asset = insert(:asset)

      {:ok, result} = Asset.get(asset.id)
      assert not is_nil(result)
      assert result.id == asset.id
    end

    test "returns error not found, if asset is not present" do
      {:error, result} = Asset.get(-1)
      assert result == "not found"
    end
  end

  describe "update/2" do
    setup do
      asset = insert(:asset)

      [asset: asset]
    end

    test "updates the asset's details", context do
      %{asset: asset} = context

      params = %{
        name: "updated asset name"
      }

      assert {:ok, asset} = Asset.update_asset(asset, params)
      assert asset.name == "updated asset name"
    end
  end

  describe "update asset position, " do
    setup [:create_asset_tree, :load_project_hierarchy]

    # asset tree initialization
    # asset_1
    # |- asset_2
    #    |- asset_4
    #    |- asset_5
    # |- asset_3

    test "move asset with descendants to root", context do
      %{project: project, hierarchy: hierarchy} = context

      [{root, _}] = hierarchy
      assert [root] == project_roots(project.id)

      [{_root, [{asset_2, asset_2_children}, _]}] = hierarchy

      Asset.update_asset(asset_2, %{parent_id: nil})
      {:ok, %{hierarchy: new_hierarchy}} = load_project_hierarchy(%{project: project})

      [{root_1, _}, {root_2, root_2_children}] = new_hierarchy

      assert [root_1, root_2] == project_roots(project.id)
      assert length(asset_2_children) == length(root_2_children)
    end

    test "move asset without descendanats to root", context do
      %{project: project, hierarchy: hierarchy} = context

      [{root, _}] = hierarchy
      assert [root] == project_roots(project.id)

      [{_root, [{_, [{asset_4, _}, _]}, _]}] = hierarchy
      assert {:ok, _asset} = Asset.update_asset(asset_4, %{parent_id: nil})
      {:ok, %{hierarchy: new_hierarchy}} = load_project_hierarchy(%{project: project})

      [{root_1, [{_asset_2, asset_2_children}, _]}, {root_2, root_2_children}] = new_hierarchy

      assert [root_1, root_2] == project_roots(project.id)
      assert root_2.name == "asset_4"
      assert root_2_children == []
      assert length(asset_2_children) == 1
    end

    test "move asset with descendants below another asset", context do
      %{project: project, hierarchy: hierarchy} = context

      [{_root, [{asset_2, asset_2_children}, {asset_3, _}]}] = hierarchy

      assert {:ok, _asset_2} = Asset.update_asset(asset_2, %{parent_id: asset_3.id})
      {:ok, %{hierarchy: new_hierarchy}} = load_project_hierarchy(%{project: project})

      [{_root, [{_asset_3, asset_3_children}]}] = new_hierarchy
      [{child_asset, child_asset_children}] = asset_3_children

      assert child_asset.name == asset_2.name
      assert length(child_asset_children) == length(asset_2_children)
    end

    test "move and update asset details at the same time", context do
      %{project: project, hierarchy: hierarchy} = context

      [{_root, [{asset_2, asset_2_children}, {asset_3, _}]}] = hierarchy

      {:ok, new_asset_2} =
        Asset.update_asset(asset_2, %{parent_id: asset_3.id, name: "asset_2_renamed"})

      assert new_asset_2.id == asset_2.id
      assert new_asset_2.name != asset_2.name

      {:ok, %{hierarchy: new_hierarchy}} = load_project_hierarchy(%{project: project})
      [{_root, [{_asset_3, asset_3_children}]}] = new_hierarchy
      [{_child_asset, child_asset_children}] = asset_3_children

      assert length(child_asset_children) == length(asset_2_children)
    end

    test "No updation if changeset errors", context do
      %{project: project, hierarchy: hierarchy} = context
      [{_root, [{asset_2, _asset_2_children}, {asset_3, _}]}] = hierarchy

      assert {:error, changeset} = Asset.update_asset(asset_2, %{parent_id: asset_3.id, name: 1})
      assert %{name: ["is invalid"]} == errors_on(changeset)
      {:ok, %{hierarchy: new_hierarchy}} = load_project_hierarchy(%{project: project})
      assert new_hierarchy == hierarchy
    end
  end

  describe "delete/1" do
    setup do
      org = insert(:organisation)
      project = insert(:project)
      user = insert(:user)
      asset_type = insert(:asset_type)

      {:ok, root_asset} =
        Asset.add_as_root(%{
          name: "asset demo",
          org_id: project.org_id,
          org_name: org.name,
          project_id: project.id,
          asset_type_id: asset_type.id,
          creator_id: user.id,
          metadata: [],
          mapped_parameters: [],
          owner_id: user.id,
          description: "Something",
          properties: []
        })

      [asset: root_asset, user: user]
    end

    test "deletes respective leaf asset", context do
      %{asset: asset} = context

      assert {:ok, {0, nil}} = Asset.delete(asset)
    end

    test "deletion of asset fails if it has child sensors", %{asset: asset} do
      sensor_manifest1 = build(:sensor, parent_id: asset.id, parent_type: "Asset")

      Repo.insert(sensor_manifest1)

      sensor_manifest2 = build(:sensor, parent_id: asset.id, parent_type: "Asset")

      Repo.insert(sensor_manifest2)

      assert {:ok, {:error, message}} = Asset.delete(asset)

      assert message ==
               "Asset #{asset.name} tree contains sensors. Please delete associated sensors before deleting asset."
    end

    test "deletion of asset will not fail if it has no child sensors", %{asset: asset} do
      assert {:ok, {0, nil}} = Asset.delete(asset)
    end

    test "deletion of asset will not fails if any of its descendant's sensor has no data", %{
      asset: asset,
      user: user
    } do
      child_asset = %AssetSchema{
        creator_id: user.id,
        description: "test one",
        mapped_parameters: [],
        metadata: [],
        name: "test asset",
        org_id: asset.org_id,
        owner_id: user.id,
        project_id: asset.project_id,
        asset_type_id: asset.asset_type_id,
        properties: []
      }

      assert {:ok, child_asset} = Asset.add_as_child(asset, child_asset, :child)

      sensor_manifest1 =
        build(:sensor, parent_id: asset.id, parent_type: "Asset", has_timesrs_data: false)

      Repo.insert(sensor_manifest1)

      sensor_manifest2 =
        build(:sensor, parent_id: child_asset.id, parent_type: "Asset", has_timesrs_data: false)

      Repo.insert(sensor_manifest2)

      assert {:ok, {0, nil}} = Asset.delete(asset)
    end
  end

  describe "add_as_root/1" do
    setup do
      asset = insert(:asset)
      org = insert(:organisation)
      project = insert(:project)
      asset_type = insert(:asset_type)

      [asset: asset, org: org, project: project, asset_type: asset_type]
    end

    test "add respective asset as root element in the tree", context do
      %{org: org, project: project, asset: asset} = context

      params = %{
        name: "asset demo",
        org_id: project.org_id,
        org_name: org.name,
        project_id: project.id,
        asset_type_id: asset.asset_type_id,
        creator_id: asset.creator_id,
        metadata: [],
        mapped_parameters: [],
        owner_id: asset.creator_id,
        properties: []
      }

      assert {:ok, root_asset} = Asset.add_as_root(params)
      refute is_nil(root_asset)
    end
  end

  describe "add_as_child/4" do
    setup do
      org = insert(:organisation)
      project = insert(:project)
      asset = insert(:asset)

      {:ok, root_asset} =
        Asset.add_as_root(%{
          name: "root asset",
          org_id: project.org_id,
          org_name: org.name,
          project_id: project.id,
          asset_type_id: asset.asset_type_id,
          creator_id: asset.creator_id,
          metadata: [],
          mapped_parameters: [],
          owner_id: asset.creator_id,
          description: "Something",
          properties: []
        })

      [parent_entity: root_asset, project: project, org: org]
    end

    test "add respective asset as root element in the tree", context do
      %{project: project, parent_entity: parent_entity, org: org} = context
      user = insert(:user)

      child_asset = %AssetSchema{
        creator_id: user.id,
        description: "test one",
        mapped_parameters: [],
        metadata: [],
        name: "test asset",
        org_id: org.id,
        owner_id: user.id,
        project_id: project.id,
        asset_type_id: parent_entity.asset_type_id,
        properties: []
      }

      assert {:ok, child_asset} = Asset.add_as_child(parent_entity, child_asset, :child)

      refute is_nil(child_asset)
    end
  end

  describe "child_assets/1" do
    setup do
      org = insert(:organisation)
      project = insert(:project)
      asset = insert(:asset)

      {:ok, root_asset} =
        Asset.add_as_root(%{
          name: "root asset",
          org_id: project.org_id,
          org_name: org.name,
          project_id: project.id,
          asset_type_id: asset.asset_type_id,
          creator_id: asset.creator_id,
          metadata: [],
          mapped_parameters: [],
          owner_id: asset.creator_id,
          description: "Something",
          properties: []
        })

      [parent_entity: root_asset]
    end

    test "show child assets", context do
      %{parent_entity: parent_entity} = context

      res = Asset.child_assets(parent_entity.project_id)

      assert length(res) != 0
    end
  end

  describe "fetch_mapped_parameters/1" do
    setup do
      org = insert(:organisation)
      project = insert(:project)
      asset = insert(:asset)

      {:ok, root_asset} =
        Asset.add_as_root(%{
          name: "root asset",
          org_id: project.org_id,
          org_name: org.name,
          project_id: project.id,
          asset_type_id: asset.asset_type_id,
          creator_id: asset.creator_id,
          metadata: [],
          mapped_parameters: [],
          owner_id: asset.creator_id,
          description: "Something",
          properties: []
        })

      sensor = build(:sensor, parent_id: root_asset.id, parent_type: "Asset")
      {:ok, _sensors_data} = Repo.insert(sensor)
      asset = Asset.child_assets(project.id)

      [asset: asset]
    end

    test "get assets mapped_parameters from sensors descendants", %{asset: asset} do
      result = Asset.fetch_mapped_parameters(List.first(asset))
      assert length(result) != 0
    end
  end

  ############## helper functions ##############################

  defp create_asset_tree(_context) do
    org = insert(:organisation)
    project = insert(:project)
    asset_type = insert(:asset_type)
    user = insert(:user)

    asset_2 = build_asset_map("asset_2", org.id, org.name, project.id, user.id, asset_type.id)
    asset_3 = build_asset_map("asset_3", org.id, org.name, project.id, user.id, asset_type.id)
    asset_4 = build_asset_map("asset_4", org.id, org.name, project.id, user.id, asset_type.id)
    asset_5 = build_asset_map("asset_5", org.id, org.name, project.id, user.id, asset_type.id)

    # asset tree initialization
    # asset_1
    # |- asset_2
    #    |- asset_4
    #    |- asset_5
    # |- asset_3

    {:ok, asset_1} =
      Asset.add_as_root(
        build_asset_root_map("asset_1", org.id, org.name, project.id, user.id, asset_type.id)
      )

    {:ok, asset_2} = Asset.add_as_child(asset_1, asset_2, :child)
    Asset.add_as_child(asset_1, asset_3, :child)
    Asset.add_as_child(asset_2, asset_4, :child)
    Asset.add_as_child(asset_2, asset_5, :child)

    {:ok,
     %{
       project: project,
       org: org
     }}
  end

  defp build_asset_root_map(name, org_id, org_name, project_id, creator_id, asset_type_id) do
    %{
      name: name,
      org_id: org_id,
      org_name: org_name,
      project_id: project_id,
      creator_id: creator_id,
      asset_type_id: asset_type_id,
      metadata: [],
      mapped_parameters: [],
      owner_id: creator_id,
      properties: []
    }
  end

  defp build_asset_map(name, org_id, _org_name, project_id, creator_id, asset_type_id) do
    %AssetSchema{
      name: name,
      org_id: org_id,
      project_id: project_id,
      creator_id: creator_id,
      asset_type_id: asset_type_id,
      metadata: [],
      mapped_parameters: [],
      owner_id: creator_id,
      properties: []
    }
  end

  defp load_project_hierarchy(%{project: project} = context) do
    hierarchy =
      AssetSchema
      |> AsNestedSet.dump(%{project_id: project.id})
      |> AsNestedSet.execute(Repo)

    {:ok, Map.merge(context, %{hierarchy: hierarchy})}
  end

  defp project_roots(project_id) do
    AssetSchema
    |> AsNestedSet.roots(%{project_id: project_id})
    |> AsNestedSet.execute(Repo)
  end
end
