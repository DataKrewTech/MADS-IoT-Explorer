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
      response = conn |> json_response(200)
      conn = post(conn, Routes.asset_type_path(conn, :create, org.id, project.id), data)
      response = conn |> json_response(400)

      assert response = %{
               "errors" => %{
                 "message" => %{"error" => %{"name" => ["asset type already exists"]}}
               }
             }
    end

    test "fails if required params are missing", %{conn: conn, org: org} do
      asset_type = insert(:asset_type)
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

  describe "index/2" do
    setup :setup_conn

    test "Asset Data", %{conn: conn, org: org} do
      test_asset = insert(:asset_type)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn =
        get(
          conn,
          Routes.asset_type_path(conn, :index, test_asset.org.id, test_asset.project.id, params)
        )

      response = conn |> json_response(200)
      assert length(response["asset_types"]) == 1
      assertion_asset = List.first(response["asset_types"])
      assert assertion_asset["id"] == test_asset.id
      assert assertion_asset["org_id"] == test_asset.org.id
    end

    test "if params are missing", %{conn: conn, org: org} do
      insert_list(3, :asset_type)
      project = insert(:project)
      conn = get(conn, Routes.asset_type_path(conn, :index, org.id, project.id, %{}))
      response = conn |> json_response(200)
      assert response["total_pages"] == 1
      assert length(response["asset_types"]) == response["total_entries"]
    end

    test "Big page size", %{conn: conn, org: org} do
      insert_list(3, :asset_type)
      project = insert(:project)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn = get(conn, Routes.asset_type_path(conn, :index, org.id, project.id, params))
      response = conn |> json_response(200)
      assert response["page_number"] == params["page_number"]
      assert response["page_size"] == params["page_size"]
      assert response["total_pages"] == 1
      assert length(response["asset_types"]) == response["total_entries"]
    end

    test "Pagination", %{conn: conn, org: org} do
      [asset_type] = insert_list(1, :asset_type)
      project = insert(:project)

      params = %{
        "page_size" => 1,
        "page_number" => 1
      }

      conn =
        get(
          conn,
          Routes.asset_type_path(conn, :index, asset_type.org.id, asset_type.project.id, params)
        )

      page1_response = conn |> json_response(200)
      assert page1_response["page_number"] == params["page_number"]
      assert page1_response["page_size"] == params["page_size"]
      assert page1_response["total_pages"] == 1
      assert length(page1_response["asset_types"]) == page1_response["page_size"]
    end

    test "fails if invalid token in authorization header", %{conn: conn, org: org} do
      bad_access_token = "qwerty1234567qwerty12"
      project = insert(:project)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn = get(conn, Routes.asset_type_path(conn, :index, org.id, project.id, params))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end
end
