# defmodule AcqdatApiWeb.DigitalTwinControllerTest do
#   use ExUnit.Case, async: true
#   use AcqdatApiWeb.ConnCase
#   use AcqdatCore.DataCase
#   import AcqdatCore.Support.Factory

#   describe "create/2" do
#     setup :setup_conn

#     test "digital twin create", %{conn: conn} do
#       process = insert(:process)

#       digital_twin_manifest = build(:digital_twin)

#       data = %{
#         name: digital_twin_manifest.name
#       }

#       params = %{
#         process_id: process.id
#       }

#       conn = post(conn, Routes.digital_twin_path(conn, :create, params), data)
#       response = conn |> json_response(200)
#       assert Map.has_key?(response, "process_id")
#       assert Map.has_key?(response, "name")
#       assert Map.has_key?(response, "id")
#     end

#     test "fails if authorization header not found", %{conn: conn} do
#       bad_access_token = "qwerty1234567uiop"

#       conn =
#         conn
#         |> put_req_header("authorization", "Bearer #{bad_access_token}")

#       data = %{}
#       conn = post(conn, Routes.digital_twin_path(conn, :create), data)
#       result = conn |> json_response(403)
#       assert result == %{"detail" => "You are not allowed to perform this action.", "source" => nil, "status_code" => 403, "title" => "Unauthorized"}
#     end

#     test "fails if sent params are not unique", %{conn: conn} do
#       digital_twin = insert(:digital_twin)

#       params = %{
#         process_id: digital_twin.process_id
#       }

#       conn = post(conn, Routes.digital_twin_path(conn, :create, params), %{})
#       response = conn |> json_response(400)

#       assert response == %{"errors" => %{"message" => %{"name" => ["can't be blank"]}}}
#     end

#     test "digital twin create when both site and process IDs are given", %{conn: conn} do
#       process = insert(:process)
#       site = insert(:site)

#       digital_twin_manifest = build(:digital_twin)

#       data = %{
#         name: digital_twin_manifest.name
#       }

#       params = %{
#         process_id: process.id,
#         site_id: site.id
#       }

#       conn = post(conn, Routes.digital_twin_path(conn, :create, params), data)
#       response = conn |> json_response(404)

#       assert response == %{
#                "errors" => %{
#                  "message" =>
#                    "Either Resource Not Found or Process and Site ID are not mutually exclusive or both are missing"
#                }
#              }
#     end

#     test "digital twin create when none site and process IDs are given", %{conn: conn} do
#       digital_twin_manifest = build(:digital_twin)

#       data = %{
#         name: digital_twin_manifest.name
#       }

#       params = %{}

#       conn = post(conn, Routes.digital_twin_path(conn, :create, params), data)
#       response = conn |> json_response(404)

#       assert response == %{
#                "errors" => %{
#                  "message" =>
#                    "Either Resource Not Found or Process and Site ID are not mutually exclusive or both are missing"
#                }
#              }
#     end
#   end

#   describe "update/2" do
#     setup :setup_conn

#     test "digital twin update", %{conn: conn} do
#       digital_twin = insert(:digital_twin)
#       data = Map.put(%{}, :name, "Water Plant")

#       conn = put(conn, Routes.digital_twin_path(conn, :update, digital_twin.id), data)
#       response = conn |> json_response(200)

#       assert Map.has_key?(response, "name")
#       assert Map.has_key?(response, "id")
#       assert Map.has_key?(response, "process_id")
#     end

#     test "fails if invalid token in authorization header", %{conn: conn} do
#       bad_access_token = "qwerty12345678qwer"
#       digital_twin = insert(:digital_twin)

#       conn =
#         conn
#         |> put_req_header("authorization", "Bearer #{bad_access_token}")

#       data = Map.put(%{}, :name, "Water Plant")
#       conn = put(conn, Routes.digital_twin_path(conn, :update, digital_twin.id), data)
#       result = conn |> json_response(403)
#       assert result == %{"detail" => "You are not allowed to perform this action.", "source" => nil, "status_code" => 403, "title" => "Unauthorized"}
#     end
#   end

#   describe "delete/2" do
#     setup :setup_conn

#     test "digital twin delete", %{conn: conn} do
#       digital_twin = insert(:digital_twin)

#       conn = delete(conn, Routes.digital_twin_path(conn, :delete, digital_twin.id), %{})
#       response = conn |> json_response(200)
#       assert Map.has_key?(response, "name")
#       assert Map.has_key?(response, "id")
#       assert Map.has_key?(response, "process_id")
#     end

#     test "fails if invalid token in authorization header", %{conn: conn} do
#       digital_twin = insert(:digital_twin)
#       bad_access_token = "qwerty1234567qwerty"

#       conn =
#         conn
#         |> put_req_header("authorization", "Bearer #{bad_access_token}")

#       conn = delete(conn, Routes.digital_twin_path(conn, :delete, digital_twin.id), %{})
#       result = conn |> json_response(403)
#       assert result == %{"detail" => "You are not allowed to perform this action.", "source" => nil, "status_code" => 403, "title" => "Unauthorized"}
#     end
#   end

#   describe "index/2" do
#     setup :setup_conn

#     test "Digital Twin Data", %{conn: conn} do
#       digital_twin = insert(:digital_twin)

#       params = %{
#         "page_size" => 100,
#         "page_number" => 1
#       }

#       conn = get(conn, Routes.digital_twin_path(conn, :index, params))
#       response = conn |> json_response(200)
#       assert length(response["digital_twin"]) == 1
#       assertion_digital_twin = List.first(response["digital_twin"])
#       assert assertion_digital_twin["id"] == digital_twin.id
#       assert assertion_digital_twin["process_id"] == digital_twin.process_id
#       assert assertion_digital_twin["process"]["id"] == digital_twin.process.id
#       assert assertion_digital_twin["process"]["name"] == digital_twin.process.name
#     end

#     test "if params are missing", %{conn: conn} do
#       insert_list(3, :digital_twin)
#       conn = get(conn, Routes.digital_twin_path(conn, :index, %{}))
#       response = conn |> json_response(200)
#       assert response["total_pages"] == 1
#       assert length(response["digital_twin"]) == response["total_entries"]
#     end

#     test "Big page size", %{conn: conn} do
#       insert_list(3, :digital_twin)

#       params = %{
#         "page_size" => 100,
#         "page_number" => 1
#       }

#       conn = get(conn, Routes.digital_twin_path(conn, :index, params))
#       response = conn |> json_response(200)
#       assert response["page_number"] == params["page_number"]
#       assert response["page_size"] == params["page_size"]
#       assert response["total_pages"] == 1
#       assert length(response["digital_twin"]) == response["total_entries"]
#     end

#     test "Pagination", %{conn: conn} do
#       insert_list(3, :digital_twin)

#       params = %{
#         "page_size" => 2,
#         "page_number" => 1
#       }

#       conn = get(conn, Routes.digital_twin_path(conn, :index, params))
#       page1_response = conn |> json_response(200)
#       assert page1_response["page_number"] == params["page_number"]
#       assert page1_response["page_size"] == params["page_size"]
#       assert page1_response["total_pages"] == 2
#       assert length(page1_response["digital_twin"]) == page1_response["page_size"]

#       params = Map.put(params, "page_number", 2)
#       conn = get(conn, Routes.digital_twin_path(conn, :index, params))
#       page2_response = conn |> json_response(200)

#       assert page2_response["page_number"] == params["page_number"]
#       assert page2_response["page_size"] == params["page_size"]
#       assert page2_response["total_pages"] == 2
#       assert length(page2_response["digital_twin"]) == 1
#     end

#     test "fails if invalid token in authorization header", %{conn: conn} do
#       bad_access_token = "qwerty1234567qwerty12"

#       conn =
#         conn
#         |> put_req_header("authorization", "Bearer #{bad_access_token}")

#       params = %{
#         "page_size" => 2,
#         "page_number" => 1
#       }

#       conn = get(conn, Routes.digital_twin_path(conn, :index, params))
#       result = conn |> json_response(403)
#       assert result == %{"detail" => "You are not allowed to perform this action.", "source" => nil, "status_code" => 403, "title" => "Unauthorized"}
#     end
#   end
# end
