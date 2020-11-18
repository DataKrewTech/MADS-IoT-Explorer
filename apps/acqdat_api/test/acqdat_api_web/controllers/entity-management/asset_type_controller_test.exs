defmodule AcqdatApiWeb.EntityManagement.AssetTypeControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_conn

    test "asset type create", %{conn: conn, org: org} do
      asset_type_manifest = build(:asset_type)
      project = insert(:project)

      data = %{
        name: asset_type_manifest.name,
        parameters: asset_type_manifest.parameters,
        metadata: asset_type_manifest.metadata
      }

      conn = post(conn, Routes.asset_type_path(conn, :create, org.id, project.id), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "org_id")
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "uuid")
      assert Map.has_key?(response, "parameters")
      assert Map.has_key?(response, "metadata")
      assert Map.has_key?(response, "slug")
    end

    test "fails if authorization header not found", %{conn: conn, org: org} do
      bad_access_token = "qwerty1234567uiop"
      project = insert(:project)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.asset_type_path(conn, :create, org.id, project.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if sent params are not unique", %{conn: conn, org: org} do
      asset_type_manifest = build(:asset_type)
      project = insert(:project)

      data = %{
        name: asset_type_manifest.name,
        parameters: asset_type_manifest.parameters,
        metadata: asset_type_manifest.metadata
      }

      conn = post(conn, Routes.asset_type_path(conn, :create, org.id, project.id), data)
      conn = post(conn, Routes.asset_type_path(conn, :create, org.id, project.id), data)
      response = conn |> json_response(400)

      assert response == %{
               "errors" => %{
                 "message" => %{"error" => %{"name" => ["asset type already exists"]}}
               }
             }
    end

    test "fails if required params are missing", %{conn: conn, org: org} do
      project = insert(:project)
      conn = post(conn, Routes.asset_type_path(conn, :create, org.id, project.id), %{})
      response = conn |> json_response(400)

      assert response == %{
               "errors" => %{
                 "message" => %{
                   "name" => ["can't be blank"]
                 }
               }
             }
    end
  end

  describe "update/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      project = insert(:project)
      [org: org, project: project]
    end

    test "asset type update", %{conn: conn, org: org, project: project} do
      asset_type = insert(:asset_type)

      data = %{
        asset_type: %{
          name: "Water Plant",
          metadata: [
            %{
              name: "metdata",
              data_type: "string",
              uuid: "test uuid"
            }
          ]
        }
      }

      conn =
        put(conn, Routes.asset_type_path(conn, :update, org.id, project.id, asset_type.id), data)

      response = conn |> json_response(200)

      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end

    test "asset type update fails, if asset is already associated with this asset_type", %{
      conn: conn,
      org: org,
      project: project
    } do
      asset = insert(:asset)

      data = %{
        asset_type: %{
          name: "Water Plant",
          metadata: [
            %{
              name: "metdata",
              data_type: "string",
              uuid: "test uuid"
            }
          ]
        }
      }

      conn =
        put(
          conn,
          Routes.asset_type_path(conn, :update, org.id, project.id, asset.asset_type_id),
          data
        )

      response = conn |> json_response(400)

      assert response == %{
               "errors" => %{"message" => "There are assets associated with this Asset Type"}
             }
    end

    test "fails if invalid token in authorization header", %{
      conn: conn,
      org: org,
      project: project
    } do
      bad_access_token = "qwerty12345678qwer"
      asset_type = insert(:asset_type)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = Map.put(%{}, :name, "Water Plant")

      conn =
        put(conn, Routes.asset_type_path(conn, :update, org.id, project.id, asset_type.id), data)

      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "delete/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      project = insert(:project)
      [org: org, project: project]
    end

    test "asset type delete", %{conn: conn, org: org, project: project} do
      asset_type = insert(:asset_type)

      conn =
        delete(
          conn,
          Routes.asset_type_path(conn, :delete, org.id, project.id, asset_type.id),
          %{}
        )

      response = conn |> json_response(200)

      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end

    test "asset type delete fails, if asset is already associated with this asset_type", %{
      conn: conn,
      org: org,
      project: project
    } do
      asset = insert(:asset)

      conn =
        delete(
          conn,
          Routes.asset_type_path(conn, :update, org.id, project.id, asset.asset_type_id),
          %{}
        )

      response = conn |> json_response(400)

      assert response == %{
               "errors" => %{
                 "message" =>
                   "There are assets associated with this Asset Type. Please delete Asset first."
               }
             }
    end

    test "fails if invalid token in authorization header", %{
      conn: conn,
      org: org,
      project: project
    } do
      asset_type = insert(:asset_type)
      bad_access_token = "qwerty1234567qwerty"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        delete(
          conn,
          Routes.asset_type_path(conn, :delete, org.id, project.id, asset_type.id),
          %{}
        )

      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end
end
