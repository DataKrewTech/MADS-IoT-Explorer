defmodule AcqdatApiWeb.ToolManagement.ToolTypeControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_conn

    test "tool type create", %{conn: conn} do
      tool_type_manifest = build(:tool_type)

      data = %{
        identifier: tool_type_manifest.identifier
      }

      conn = post(conn, Routes.tool_type_path(conn, :create), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "identifier")
    end

    test "fails if authorization header not found", %{conn: conn} do
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.tool_type_path(conn, :create), data)
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    # test "fails if sent params are not unique", %{conn: conn} do
    #   tool_type_manifest = insert(:tool_type)

    #   data = %{
    #     identifier: tool_type_manifest.identifier
    #   }

    #   conn = post(conn, Routes.tool_type_path(conn, :create), data)
    #   response = conn |> json_response(400)

    #   assert response == %{
    #            "errors" => %{
    #              "message" => %{"error" => %{"identifier" => ["Tool type already exists!"]}}
    #            }
    #          }
    # end

    test "fails if required params are missing", %{conn: conn} do
      conn = post(conn, Routes.tool_type_path(conn, :create), %{})
      response = conn |> json_response(400)

      assert response == %{
               "detail" =>
                 "Parameters provided to perform current action is either not valid or missing or not unique",
               "source" => %{"identifier" => ["can't be blank"]},
               "status_code" => 400,
               "title" => "Insufficient or not unique parameters"
             }
    end
  end

  describe "update/2" do
    setup :setup_conn

    test "tool_type update", %{conn: conn} do
      tool_type = insert(:tool_type)
      data = Map.put(%{}, :name, "nails")

      conn = put(conn, Routes.tool_type_path(conn, :update, tool_type.id), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "identifier")
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "avcbd123489u"
      tool_type = insert(:tool_type)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = Map.put(%{}, :name, "Bolts")
      conn = put(conn, Routes.tool_type_path(conn, :update, tool_type.id), data)
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end
  end

  describe "index/2" do
    setup :setup_conn

    test "Big page size", %{conn: conn} do
      insert_list(3, :tool_type)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn = get(conn, Routes.tool_type_path(conn, :index, params))
      response = conn |> json_response(200)
      assert response["page_number"] == params["page_number"]
      assert response["page_size"] == params["page_size"]
      assert response["total_pages"] == 1
      assert length(response["tool_type"]) == response["total_entries"]
    end

    test "Pagination", %{conn: conn} do
      insert_list(3, :tool_type)

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn = get(conn, Routes.tool_type_path(conn, :index, params))
      page1_response = conn |> json_response(200)
      assert page1_response["page_number"] == params["page_number"]
      assert page1_response["page_size"] == params["page_size"]
      assert page1_response["total_pages"] == 2
      assert length(page1_response["tool_type"]) == page1_response["page_size"]

      params = Map.put(params, "page_number", 2)
      conn = get(conn, Routes.tool_type_path(conn, :index, params))
      page2_response = conn |> json_response(200)

      assert page2_response["page_number"] == params["page_number"]
      assert page2_response["page_size"] == params["page_size"]
      assert page2_response["total_pages"] == 2
      assert length(page2_response["tool_type"]) == 1
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "avcbd12 3489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn = get(conn, Routes.tool_type_path(conn, :index, params))
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end
  end

  describe "delete/2" do
    setup :setup_conn

    test "tool_type delete", %{conn: conn} do
      tool_type = insert(:tool_type)

      conn = delete(conn, Routes.tool_type_path(conn, :delete, tool_type.id), %{})
      response = conn |> json_response(200)
      assert Map.has_key?(response, "identifier")
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      tool_type = insert(:tool_type)
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = delete(conn, Routes.tool_type_path(conn, :delete, tool_type.id), %{})
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end
  end
end
