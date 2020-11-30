defmodule AcqdatApiWeb.EntityManagement.AssetControllerTest do
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

      conn = get(conn, Routes.assets_path(conn, :show, 1, 1, params.id))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "asset with invalid asset id", %{conn: conn} do
      params = %{
        id: -1
      }

      conn = get(conn, Routes.assets_path(conn, :show, 1, 1, params.id))
      result = conn |> json_response(404)
      assert result == %{"errors" => %{"message" => "Resource Not Found"}}
    end

    test "asset with valid id", %{conn: conn, asset: asset} do
      conn = get(conn, Routes.assets_path(conn, :show, asset.org.id, asset.project.id, asset.id))
      result = conn |> json_response(200)

      refute is_nil(result)

      assert Map.has_key?(result, "id")
      assert Map.has_key?(result, "name")
      assert Map.has_key?(result, "creator_id")
      assert Map.has_key?(result, "asset_type_id")
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

      conn = put(conn, Routes.assets_path(conn, :update, 1, 1, 1, params))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "updated asset successfully", %{conn: conn, asset: asset} do
      params = %{
        asset: %{
          name: "updated asset name"
        }
      }

      conn =
        put(
          conn,
          Routes.assets_path(conn, :update, asset.org.id, asset.project.id, asset.id, params)
        )

      metadata =
        Enum.reduce(asset.metadata, [], fn x, acc ->
          %{id: id, data_type: data_type, name: name, unit: unit, uuid: uuid, value: value} =
            Map.from_struct(x)

          changes = %{
            "name" => name,
            "data_type" => data_type,
            "unit" => unit,
            "uuid" => uuid,
            "id" => id,
            "value" => value
          }

          [changes | acc]
        end)

      result = conn |> json_response(200)

      assert result == %{
               "description" => asset.description,
               "id" => asset.id,
               "name" => asset.name,
               "properties" => asset.properties,
               "metadata" => Enum.reverse(metadata),
               "type" => "Asset",
               "asset_type_id" => asset.asset_type_id,
               "creator_id" => asset.creator_id,
               "parent_id" => asset.parent_id
             }
    end
  end

  describe "create/2" do
    setup :setup_conn

    test "asset type create", %{conn: conn, org: org, user: user} do
      asset_manifest = build(:asset)
      project = insert(:project)
      asset_type = insert(:asset_type)

      data = %{
        name: asset_manifest.name,
        mapped_parameters: asset_manifest.mapped_parameters,
        metadata: asset_manifest.metadata,
        creator_id: user.id,
        project_id: project.id,
        asset_type_id: asset_type.id
      }

      conn = post(conn, Routes.assets_path(conn, :create, org.id, project.id), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end

    test "fails if authorization header not found", %{conn: conn, org: org} do
      bad_access_token = "qwerty1234567uiop"
      project = insert(:project)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.assets_path(conn, :create, org.id, project.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    # test "fails if sent params are not unique", %{conn: conn, org: org, user: user} do
    #   asset_manifest = build(:asset)
    #   data = %{
    #     name: asset_manifest.name,
    #     mapped_parameters: asset_manifest.mapped_parameters,
    #     metadata: asset_manifest.metadata,
    #     creator_id: user.id
    #   }

    #   conn = post(conn, Routes.assets_path(conn, :create, org.id), data)
    #   conn = post(conn, Routes.assets_path(conn, :create, org.id), data)
    #   response = conn |> json_response(400)

    #   assert response == %{
    #            "errors" => %{
    #              "message" => %{"error" => %{"name" => ["asset already exists"]}}
    #            }
    #          }
    # end

    test "fails if required params are missing", %{conn: conn, org: org} do
      asset = insert(:asset)
      project = insert(:project)
      insert(:asset_type)

      conn =
        post(conn, Routes.assets_path(conn, :create, org.id, project.id), %{
          asset_type_id: asset.asset_type_id
        })

      response = conn |> json_response(400)

      assert response == %{
               "errors" => %{
                 "message" => %{
                   "creator_id" => ["can't be blank"]
                 }
               }
             }
    end
  end

  describe "delete/2" do
    setup :setup_conn

    test "asset delete", %{conn: conn, org: org} do
      asset = insert(:asset)
      project = insert(:project)
      conn = delete(conn, Routes.assets_path(conn, :delete, org.id, project.id, asset.id), %{})
      response = conn |> json_response(200)

      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "properties")
    end

    test "fails if invalid token in authorization header", %{conn: conn, org: org} do
      asset = insert(:asset)
      bad_access_token = "qwerty1234567qwerty"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        delete(conn, Routes.assets_path(conn, :delete, org.id, asset.project.id, asset.id), %{})

      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end
end
