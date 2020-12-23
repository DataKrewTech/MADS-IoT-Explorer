defmodule AcqdatApiWeb.ElasticSearch.AssetControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Factory.ElasticSearch.Asset
  import AcqdatCore.Support.Factory

  describe "search_assets/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn} do
      asset = insert(:asset)
      Asset.seed_asset(asset)
      :timer.sleep(2500)
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(
          conn,
          Routes.search_assets_path(conn, :search_assets, asset.org_id, asset.project_id),
          %{
            "label" => asset.name
          }
        )

      result = conn |> json_response(403)
      Asset.delete_index()
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "search with valid params", %{conn: conn} do
      asset = insert(:asset)
      Asset.seed_asset(asset)
      :timer.sleep(2500)

      conn =
        get(
          conn,
          Routes.search_assets_path(conn, :search_assets, asset.org_id, asset.project_id),
          %{
            "label" => asset.name
          }
        )

      result = conn |> json_response(200)

      Asset.delete_index()
      asset_type = asset.asset_type

      assert result == %{
               "assets" => [
                 %{
                   "id" => asset.id,
                   "name" => asset.name,
                   "properties" => asset.properties,
                   "asset_type_id" => asset.asset_type_id,
                   "creator_id" => asset.creator_id,
                   "description" => asset.description,
                   "parent_id" => asset.parent_id,
                   "type" => "Asset",
                   "asset_type" => %{
                     "description" => asset_type.description,
                     "id" => asset_type.id,
                     "metadata" => convert_list_of_struct_to_list_of_map(asset_type.metadata),
                     "name" => asset_type.name,
                     "org_id" => asset_type.org_id,
                     "parameters" => convert_list_of_struct_to_list_of_map(asset_type.parameters),
                     "project_id" => asset_type.project_id,
                     "sensor_type_present" => asset_type.sensor_type_present,
                     "sensor_type_uuid" => asset_type.sensor_type_uuid,
                     "slug" => asset_type.slug,
                     "uuid" => asset_type.uuid
                   },
                   "metadata" => convert_list_of_struct_to_list_of_map(asset.metadata)
                 }
               ],
               "total_entries" => 1
             }
    end

    test "search with no hits", %{conn: conn} do
      asset = insert(:asset)
      Asset.seed_asset(asset)
      :timer.sleep(2500)
      project = insert(:project)

      conn =
        get(
          conn,
          Routes.search_assets_path(conn, :search_assets, project.org_id, project.id),
          %{
            "label" => asset.name
          }
        )

      result = conn |> json_response(200)

      Asset.delete_index()

      assert result == %{
               "assets" => [],
               "total_entries" => 0
             }
    end
  end

  describe "index assets/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn} do
      project = insert(:project)
      Asset.seed_multiple_assets(project)
      :timer.sleep(2500)
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(conn, Routes.assets_path(conn, :index, project.org_id, project.id), %{
          "from" => 0,
          "page_size" => 1
        })

      result = conn |> json_response(403)
      Asset.delete_index()
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "index with valid params and multiple entries", %{conn: conn} do
      project = insert(:project)
      [asset1, asset2, asset3] = Asset.seed_multiple_assets(project)
      :timer.sleep(2500)

      conn =
        get(conn, Routes.assets_path(conn, :index, project.org_id, project.id), %{
          "from" => 0,
          "page_size" => 3
        })

      %{"assets" => assets} = conn |> json_response(200)

      Asset.delete_index()
      assert length(assets) == 3
      [rasset1, rasset2, rasset3] = assets
      assert rasset1["id"] == asset1.id
      assert rasset2["id"] == asset2.id
      assert rasset3["id"] == asset3.id
    end
  end

  describe "update and delete assets/2" do
    setup :setup_conn

    test "if asset is updated", %{conn: conn} do
      asset = insert(:asset)
      Asset.seed_asset(asset)
      :timer.sleep(2500)

      conn =
        put(conn, Routes.assets_path(conn, :update, asset.org_id, asset.project_id, asset.id), %{
          "name" => "Testing Asset"
        })

      :timer.sleep(2500)

      conn =
        get(
          conn,
          Routes.search_assets_path(conn, :search_assets, asset.org_id, asset.project_id),
          %{
            "label" => "Testing Asset"
          }
        )

      result = conn |> json_response(200)

      Asset.delete_index()
      asset_type = asset.asset_type

      assert result == %{
               "assets" => [
                 %{
                   "id" => asset.id,
                   "name" => "Testing Asset",
                   "properties" => asset.properties,
                   "asset_type_id" => asset.asset_type_id,
                   "creator_id" => asset.creator_id,
                   "description" => asset.description,
                   "parent_id" => asset.parent_id,
                   "type" => "Asset",
                   "asset_type" => %{
                     "description" => asset_type.description,
                     "id" => asset_type.id,
                     "metadata" => convert_list_of_struct_to_list_of_map(asset_type.metadata),
                     "name" => asset_type.name,
                     "org_id" => asset_type.org_id,
                     "parameters" => convert_list_of_struct_to_list_of_map(asset_type.parameters),
                     "project_id" => asset_type.project_id,
                     "sensor_type_present" => asset_type.sensor_type_present,
                     "sensor_type_uuid" => asset_type.sensor_type_uuid,
                     "slug" => asset_type.slug,
                     "uuid" => asset_type.uuid
                   },
                   "metadata" => convert_list_of_struct_to_list_of_map(asset.metadata)
                 }
               ],
               "total_entries" => 1
             }
    end

    test "if asset is deleted", %{conn: conn} do
      asset = insert(:asset)
      Asset.seed_asset(asset)
      :timer.sleep(2500)

      conn =
        delete(conn, Routes.assets_path(conn, :delete, asset.org_id, asset.project_id, asset.id))

      :timer.sleep(2500)

      conn =
        get(
          conn,
          Routes.search_assets_path(conn, :search_assets, asset.org_id, asset.project_id),
          %{
            "label" => asset.name
          }
        )

      result = conn |> json_response(200)

      Asset.delete_index()

      assert result == %{
               "assets" => [],
               "total_entries" => 0
             }
    end
  end

  defp convert_list_of_struct_to_list_of_map(params) do
    Enum.reduce(params, [], fn x, acc ->
      acc ++ [convert_atom_key_to_string(Map.from_struct(x))]
    end)
  end

  defp convert_atom_key_to_string(params) do
    for {key, val} <- params, into: %{}, do: {Atom.to_string(key), val}
  end
end
