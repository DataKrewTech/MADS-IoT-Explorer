defmodule AcqdatApiWeb.AssetControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "show/2" do
    setup :setup_conn

    setup do
      asset = insert(:asset)

      [asset: asset]
    end

    test "fails if invalid token in in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        id: 3
      }

      conn = get(conn, Routes.asset_path(conn, :show, 1, params.id))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "asset with invalid asset id", %{conn: conn, org: org} do
      params = %{
        id: -1
      }

      conn = get(conn, Routes.asset_path(conn, :show, 1, params.id))
      result = conn |> json_response(404)
      assert result == %{"errors" => %{"message" => "Resource Not Found"}}
    end

    test "asset with valid id", %{conn: conn, asset: asset} do
      conn = get(conn, Routes.asset_path(conn, :show, asset.org.id, asset.id))
      result = conn |> json_response(200)

      assert result == %{
               "entities" => '',
               "id" => asset.id,
               "name" => asset.name,
               "type" => "Asset",
               "parent_id" => -1,
               "properties" => []
             }
    end
  end

  describe "update/2" do
    setup :setup_conn

    setup do
      asset = insert(:asset)

      [asset: asset]
    end

    test "fails if invalid token in in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        asset: %{}
      }

      conn = put(conn, Routes.asset_path(conn, :update, 1, 1, params))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "updated asset successfully", %{conn: conn, asset: asset} do
      params = %{
        asset: %{
          name: "updated asset name"
        }
      }

      conn = put(conn, Routes.asset_path(conn, :update, asset.org.id, asset.id, params))
      result = conn |> json_response(200)

      assert result == %{
               "id" => asset.id,
               "name" => "updated asset name",
               "properties" => '',
               "type" => "Asset",
               "description" => nil,
               "mapped_parameters" => []
             }
    end
  end
end
