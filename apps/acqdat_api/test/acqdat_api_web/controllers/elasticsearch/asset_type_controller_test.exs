defmodule AcqdatApiWeb.ElasticSearch.AssetTypeControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Factory.ElasticSearch.AssetType
  import AcqdatCore.Support.Factory

  describe "search_assets_type/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn} do
      asset_type = insert(:asset_type)
      AssetType.seed_asset_type(asset_type)
      :timer.sleep(2500)
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(
          conn,
          Routes.search_asset_type_path(
            conn,
            :search_asset_type,
            asset_type.org_id,
            asset_type.project_id
          ),
          %{
            "label" => asset_type.name
          }
        )

      result = conn |> json_response(403)
      AssetType.delete_index()
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "search with valid params", %{conn: conn} do
      asset_type = insert(:asset_type)
      AssetType.seed_asset_type(asset_type)
      :timer.sleep(2500)

      conn =
        get(
          conn,
          Routes.search_asset_type_path(
            conn,
            :search_asset_type,
            asset_type.org_id,
            asset_type.project_id
          ),
          %{
            "label" => asset_type.name
          }
        )

      %{
        "asset_types" => [
          rasset_type
        ]
      } = conn |> json_response(200)

      AssetType.delete_index()
      assert rasset_type["id"] == asset_type.id
      assert rasset_type["project_id"] == asset_type.project_id
      assert rasset_type["slug"] == asset_type.slug
      assert rasset_type["uuid"] == asset_type.uuid
      assert rasset_type["name"] == asset_type.name
    end

    test "search with no hits", %{conn: conn} do
      asset_type = insert(:asset_type)
      AssetType.seed_asset_type(asset_type)
      :timer.sleep(2500)

      conn =
        get(
          conn,
          Routes.search_asset_type_path(
            conn,
            :search_asset_type,
            asset_type.org_id,
            asset_type.project_id
          ),
          %{
            "label" => "Random Name ?"
          }
        )

      result = conn |> json_response(200)

      AssetType.delete_index()

      assert result == %{
               "asset_types" => [],
               "total_entries" => 0
             }
    end
  end

  describe "index asset types/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn} do
      project = insert(:project)
      AssetType.seed_multiple_assets_type(project)
      :timer.sleep(2500)
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(conn, Routes.asset_type_path(conn, :index, project.org_id, project.id), %{
          "from" => 0,
          "page_size" => 1
        })

      result = conn |> json_response(403)
      AssetType.delete_index()
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "index with valid params and multiple entries", %{conn: conn} do
      project = insert(:project)
      [asset_type1, asset_type2, asset_type3] = AssetType.seed_multiple_assets_type(project)
      :timer.sleep(2500)

      conn =
        get(conn, Routes.asset_type_path(conn, :index, project.org_id, project.id), %{
          "from" => 0,
          "page_size" => 3
        })

      %{"asset_types" => asset_types} = conn |> json_response(200)

      AssetType.delete_index()
      assert length(asset_types) == 3
      [rasset_type1, rasset_type2, rasset_type3] = asset_types
      assert rasset_type1["id"] == asset_type1.id
      assert rasset_type2["id"] == asset_type2.id
      assert rasset_type3["id"] == asset_type3.id
    end
  end

  describe "update and delete asset type/2" do
    setup :setup_conn

    test "if asset type is updated", %{conn: conn} do
      asset_type = insert(:asset_type)
      AssetType.seed_asset_type(asset_type)
      :timer.sleep(2500)

      conn =
        put(
          conn,
          Routes.asset_type_path(
            conn,
            :update,
            asset_type.org_id,
            asset_type.project_id,
            asset_type.id
          ),
          %{
            "name" => "Random Name ?"
          }
        )

      :timer.sleep(2500)

      conn =
        get(
          conn,
          Routes.search_asset_type_path(
            conn,
            :search_asset_type,
            asset_type.org_id,
            asset_type.project_id
          ),
          %{
            "label" => "Random Name ?"
          }
        )

      %{
        "asset_types" => [
          rasset_type
        ]
      } = conn |> json_response(200)

      AssetType.delete_index()
      assert rasset_type["id"] == asset_type.id
      assert rasset_type["project_id"] == asset_type.project_id
      assert rasset_type["slug"] == asset_type.slug
      assert rasset_type["uuid"] == asset_type.uuid
      assert rasset_type["name"] == "Random Name ?"
    end

    test "if asset type is deleted", %{conn: conn} do
      asset_type = insert(:asset_type)
      AssetType.seed_asset_type(asset_type)
      :timer.sleep(2500)

      conn =
        delete(
          conn,
          Routes.asset_type_path(
            conn,
            :update,
            asset_type.org_id,
            asset_type.project_id,
            asset_type.id
          )
        )

      :timer.sleep(2500)

      conn =
        get(
          conn,
          Routes.search_asset_type_path(
            conn,
            :search_asset_type,
            asset_type.org_id,
            asset_type.project_id
          ),
          %{
            "label" => asset_type.name
          }
        )

      result = conn |> json_response(200)

      AssetType.delete_index()

      assert result == %{
               "asset_types" => [],
               "total_entries" => 0
             }
    end
  end
end
