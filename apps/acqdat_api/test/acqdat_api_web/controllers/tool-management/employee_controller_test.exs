defmodule AcqdatApiWeb.ToolManagement.EmployeeControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_conn

    test "employee create", %{conn: conn} do
      employee_manifest = build(:employee)

      data = %{
        name: employee_manifest.name,
        phone_number: employee_manifest.phone_number,
        role: "supervisor",
        uuid: employee_manifest.uuid,
        address: employee_manifest.address
      }

      conn = post(conn, Routes.employee_path(conn, :create), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "phone_number")
      assert Map.has_key?(response, "role")
      assert Map.has_key?(response, "address")
      assert Map.has_key?(response, "uuid")
    end

    test "fails if authorization header not found", %{conn: conn} do
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.employee_path(conn, :create), data)
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    # test "fails if sent params are not unique", %{conn: conn} do
    #   employee_manifest = insert(:employee)

    #   data = %{
    #     name: employee_manifest.name,
    #     phone_number: employee_manifest.phone_number,
    #     role: "supervisor",
    #     uuid: employee_manifest.uuid,
    #     address: employee_manifest.address
    #   }

    #   conn = post(conn, Routes.employee_path(conn, :create), data)
    #   response = conn |> json_response(400)

    #   assert response == %{
    #            "errors" => %{
    #              "message" => %{"error" => %{"name" => ["User already exists!"]}}
    #            }
    #          }
    # end

    test "fails if required params are missing", %{conn: conn} do
      conn = post(conn, Routes.employee_path(conn, :create), %{})
      response = conn |> json_response(400)

      assert response == %{
               "detail" =>
                 "Parameters provided to perform current action is either not valid or missing or not unique",
               "source" => %{
                 "name" => ["can't be blank"],
                 "phone_number" => ["can't be blank"],
                 "role" => ["can't be blank"]
               },
               "status_code" => 400,
               "title" => "Insufficient or not unique parameters"
             }
    end
  end

  describe "update/2" do
    setup :setup_conn

    test "employee update", %{conn: conn} do
      employee = insert(:employee)
      data = Map.put(%{}, :name, "Vikram")

      conn = put(conn, Routes.employee_path(conn, :update, employee.id), data)
      response = conn |> json_response(200)

      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "phone_number")
      assert Map.has_key?(response, "role")
      assert Map.has_key?(response, "address")
      assert Map.has_key?(response, "uuid")
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "avcbd123489u"
      employee = insert(:employee)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = Map.put(%{}, :name, "Vikram")
      conn = put(conn, Routes.employee_path(conn, :update, employee.id), data)
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
      insert_list(3, :employee)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn = get(conn, Routes.employee_path(conn, :index, params))
      response = conn |> json_response(200)
      assert response["page_number"] == params["page_number"]
      assert response["page_size"] == params["page_size"]
      assert response["total_pages"] == 1
      assert length(response["employee"]) == response["total_entries"]
    end

    test "Pagination", %{conn: conn} do
      insert_list(3, :employee)

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn = get(conn, Routes.employee_path(conn, :index, params))
      page1_response = conn |> json_response(200)
      assert page1_response["page_number"] == params["page_number"]
      assert page1_response["page_size"] == params["page_size"]
      assert page1_response["total_pages"] == 2
      assert length(page1_response["employee"]) == page1_response["page_size"]

      params = Map.put(params, "page_number", 2)
      conn = get(conn, Routes.employee_path(conn, :index, params))
      page2_response = conn |> json_response(200)

      assert page2_response["page_number"] == params["page_number"]
      assert page2_response["page_size"] == params["page_size"]
      assert page2_response["total_pages"] == 2
      assert length(page2_response["employee"]) == 1
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

      conn = get(conn, Routes.employee_path(conn, :index, params))
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

    test "employee delete", %{conn: conn} do
      employee = insert(:employee)

      conn = delete(conn, Routes.employee_path(conn, :delete, employee.id), %{})
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "phone_number")
      assert Map.has_key?(response, "role")
      assert Map.has_key?(response, "address")
      assert Map.has_key?(response, "uuid")
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      employee = insert(:employee)
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = delete(conn, Routes.employee_path(conn, :delete, employee.id), %{})
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
