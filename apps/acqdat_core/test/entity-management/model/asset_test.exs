defmodule AcqdatCore.Model.EntityManagement.AssetTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory

  alias AcqdatCore.Model.EntityManagement.Asset

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

  describe "delete/1" do
    setup do
      asset = insert(:asset)

      [asset: asset]
    end

    test "deletes respective asset", context do
      %{asset: asset} = context

      assert {0, nil} = Asset.delete(asset)
    end
  end

  describe "add_as_root/1" do
    setup do
      asset = insert(:asset)
      org = insert(:organisation)
      project = insert(:project)

      [asset: asset, org: org, project: project]
    end

    test "add respective asset as root element in the tree", context do
      %{org: org, project: project} = context

      params = %{
        name: "asset demo",
        org_id: project.org_id,
        org_name: org.name,
        project_id: project.id
      }

      assert {:ok, root_asset} = Asset.add_as_root(params)
      refute is_nil(root_asset)
    end
  end

  describe "add_as_child/4" do
    setup do
      org = insert(:organisation)
      project = insert(:project)

      {:ok, root_asset} =
        Asset.add_as_root(%{
          name: "root asset",
          org_id: project.org_id,
          org_name: org.name,
          project_id: project.id
        })

      [parent_entity: root_asset, project: project]
    end

    test "add respective asset as root element in the tree", context do
      %{project: project, parent_entity: parent_entity} = context

      assert {:ok, child_asset} =
               Asset.add_as_child(parent_entity, "child asset", project.org_id, :child)

      refute is_nil(child_asset)
    end
  end

  describe "child_assets/1" do
    setup do
      org = insert(:organisation)
      project = insert(:project)

      {:ok, root_asset} =
        Asset.add_as_root(%{
          name: "root asset",
          org_id: project.org_id,
          org_name: org.name,
          project_id: project.id
        })

      [parent_entity: root_asset]
    end

    test "show child assets", context do
      %{parent_entity: parent_entity} = context

      res = Asset.child_assets(parent_entity.project_id)

      assert length(res) != 0
    end
  end
end
