defmodule AcqdatApiWeb.AssetControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_conn

    test "asset type create", %{conn: conn, org: org, user: user} do
      asset_manifest = build(:asset)
      project = insert(:project)

      data = %{
        name: asset_manifest.name,
        mapped_parameters: asset_manifest.mapped_parameters,
        metadata: asset_manifest.metadata,
        creator_id: user.id,
        project_id: project.id
      }

      conn = post(conn, Routes.asset_path(conn, :create, org.id), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "mapped_parameters")
    end

    test "fails if authorization header not found", %{conn: conn, org: org} do
      bad_access_token = "qwerty1234567uiop"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.asset_path(conn, :create, org.id), data)
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

    #   conn = post(conn, Routes.asset_path(conn, :create, org.id), data)
    #   conn = post(conn, Routes.asset_path(conn, :create, org.id), data)
    #   response = conn |> json_response(400)

    #   assert response == %{
    #            "errors" => %{
    #              "message" => %{"error" => %{"name" => ["asset already exists"]}}
    #            }
    #          }
    # end

    test "fails if required params are missing", %{conn: conn, org: org} do
      asset = insert(:asset)

      conn = post(conn, Routes.asset_path(conn, :create, org.id), %{})

      response = conn |> json_response(400)

      assert response == %{
               "errors" => %{
                 "message" => %{
                   "creator_id" => ["can't be blank"],
                   "project_id" => ["can't be blank"]
                 }
               }
             }
    end
  end

  describe "update/2" do
    setup :setup_conn

    test "asset update", %{conn: conn, org: org} do
      asset = insert(:asset)
      data = Map.put(%{}, :name, "Water Plant")

      conn = put(conn, Routes.asset_path(conn, :update, org.id, asset.id), data)

      response = conn |> json_response(200)

      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "mapped_parameters")
      assert Map.has_key?(response, "properties")
      assert Map.has_key?(response, "type")
    end

    test "fails if invalid token in authorization header", %{conn: conn, org: org} do
      asset = insert(:asset)
      bad_access_token = "qwerty1234567qwerty"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = put(conn, Routes.asset_path(conn, :update, org.id, asset.id), %{})
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "delete/2" do
    setup :setup_conn

    test "asset delete", %{conn: conn, org: org} do
      asset = insert(:asset)

      conn = delete(conn, Routes.asset_path(conn, :delete, org.id, asset.id), %{})
      response = conn |> json_response(200)

      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "mapped_parameters")
      assert Map.has_key?(response, "properties")
    end

    test "fails if invalid token in authorization header", %{conn: conn, org: org} do
      asset = insert(:asset)
      bad_access_token = "qwerty1234567qwerty"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = delete(conn, Routes.asset_path(conn, :delete, org.id, asset.id), %{})
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "index/2" do
    setup :setup_conn

    test "Asset Data", %{conn: conn, org: org} do
      asset = insert(:asset)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn = get(conn, Routes.asset_path(conn, :index, org.id, params))
      response = conn |> json_response(200)

      assert length(response["assets"]) == 1
      assertion_asset = List.first(response["assets"])
      assert assertion_asset["id"] == asset.id
      assert assertion_asset["name"] == asset.name
      assert assertion_asset["properties"] == asset.properties
    end

    test "if params are missing", %{conn: conn, org: org} do
      insert_list(3, :asset)
      conn = get(conn, Routes.asset_path(conn, :index, org.id, %{}))
      response = conn |> json_response(200)
      assert response["total_pages"] == 1
      assert length(response["assets"]) == response["total_entries"]
    end

    test "Big page size", %{conn: conn, org: org} do
      insert_list(3, :asset)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn = get(conn, Routes.asset_path(conn, :index, org.id, params))
      response = conn |> json_response(200)
      assert response["page_number"] == params["page_number"]
      assert response["page_size"] == params["page_size"]
      assert response["total_pages"] == 1
      assert length(response["assets"]) == response["total_entries"]
    end

    test "Pagination", %{conn: conn, org: org} do
      insert_list(3, :asset)

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn = get(conn, Routes.asset_path(conn, :index, org.id, params))
      page1_response = conn |> json_response(200)
      assert page1_response["page_number"] == params["page_number"]
      assert page1_response["page_size"] == params["page_size"]
      assert page1_response["total_pages"] == 2
      assert length(page1_response["assets"]) == page1_response["page_size"]

      params = Map.put(params, "page_number", 2)
      conn = get(conn, Routes.asset_path(conn, :index, org.id, params))
      page2_response = conn |> json_response(200)

      assert page2_response["page_number"] == params["page_number"]
      assert page2_response["page_size"] == params["page_size"]
      assert page2_response["total_pages"] == 2
      assert length(page2_response["assets"]) == 1
    end

    test "fails if invalid token in authorization header", %{conn: conn, org: org} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn = get(conn, Routes.asset_path(conn, :index, org.id, params))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end
end
