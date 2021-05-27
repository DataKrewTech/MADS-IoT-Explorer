defmodule AcqdatCore.Model.EntityManagement.AssetTypeTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.EntityManagement.AssetType

  describe "update/2" do
    setup do
      asset = insert(:asset)

      asset_type = insert(:asset_type)

      [asset: asset, asset_type: asset_type]
    end

    test "updates asset_type details which does not have any asset attached to it", context do
      %{asset_type: asset_type} = context

      params = %{
        name: "updated asset type name",
        description: "description",
        metadata: [
          %{
            data_type: "string",
            name: "no of floors"
          }
        ]
      }

      assert {:ok, asset_type} = AssetType.update(asset_type, params)
      assert asset_type.name == "updated asset type name"
      assert asset_type.description == "description"
    end

    test "updates asset_type(connected to assets) params except metadata", context do
      %{asset: asset} = context

      {:ok, asset_type} = AssetType.get(asset.asset_type_id)

      params = %{
        name: "updated asset type name",
        description: "description"
      }

      assert {:ok, updated_asset_type} = AssetType.update(asset_type, params)
      assert updated_asset_type.name == "updated asset type name"
      assert updated_asset_type.description == "description"
      assert updated_asset_type.metadata == asset_type.metadata
    end

    test "cannot update asset_type(attached to assets)'s' existing metadata", context do
      %{asset: asset} = context

      {:ok, asset_type} = AssetType.get(asset.asset_type_id)

      metadata =
        Enum.reduce(asset_type.metadata, [], fn metadata, acc ->
          acc ++
            [
              %{
                "name" => "updated metadata name",
                "data_type" => metadata.data_type,
                "unit" => metadata.unit,
                "id" => metadata.id,
                "uuid" => metadata.uuid
              }
            ]
        end)

      params = %{
        "name" => "updated asset type name",
        "description" => "description",
        "metadata" => metadata
      }

      assert {:error, error_msg} = AssetType.update(asset_type, params)
      assert error_msg == "There are assets associated with this Asset Type"
    end

    test "cannot delete asset_type(attached to assets)'s existing metadata", context do
      %{asset: asset} = context

      {:ok, asset_type} = AssetType.get(asset.asset_type_id)

      metadata =
        Enum.reduce(asset_type.metadata, [], fn metadata, _acc ->
          [
            %{
              "name" => "updated metadata name",
              "data_type" => metadata.data_type,
              "unit" => metadata.unit,
              "id" => metadata.id,
              "uuid" => metadata.uuid
            }
          ]
        end)

      params = %{
        "name" => "updated asset type name",
        "description" => "description",
        "metadata" => metadata
      }

      assert {:error, error_msg} = AssetType.update(asset_type, params)
      assert error_msg == "There are assets associated with this Asset Type"
    end

    test "can append new metadata to asset_type(attached to assets)'s existing metadata",
         context do
      %{asset: asset} = context

      {:ok, asset_type} = AssetType.get(asset.asset_type_id)

      metadata = [
        %{
          "name" => "new metadata name",
          "data_type" => "string",
          "unit" => ""
        }
      ]

      params = %{
        "name" => "updated asset type name",
        "description" => "description",
        "metadata" => metadata
      }

      assert {:ok, updated_asset_type} = AssetType.update(asset_type, params)

      assert updated_asset_type.name == "updated asset type name"
      assert updated_asset_type.description == "description"
      assert length(updated_asset_type.metadata) == length(asset_type.metadata) + 1
    end
  end
end
