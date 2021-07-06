defmodule AcqdatApiWeb.RoleManagement.RequestsControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "update/2" do
    setup :setup_conn

    setup do
      request = insert(:request)

      [request: request]
    end

    test "requests rejected by the superadmin", context do
      %{request: request, conn: conn} = context

      conn =
        put(conn, Routes.requests_path(conn, :update, request.id), %{
          "status" => "reject"
        })

      response = conn |> json_response(200)

      assert response["status"] ==
               "Successfully Rejected the Request"
    end

    test "requests accepted by the superadmin", context do
      %{request: request, conn: conn} = context

      insert(:role, name: "orgadmin")

      conn =
        put(conn, Routes.requests_path(conn, :update, request.id), %{
          "status" => "accept"
        })

      response = conn |> json_response(200)

      assert response["status"] ==
               "Sent invitation to the user successfully, they will receive email after sometime!"
    end

    test "fails if invalid token in authorization header", context do
      %{request: requests, conn: conn} = context
      bad_access_token = "qwerty1234567qwerty"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = put(conn, Routes.requests_path(conn, :update, requests.id), %{})

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

    test "show all the requests", context do
      %{conn: conn} = context

      params = %{
        page_size: 10,
        page_number: 1
      }

      insert_list(3, :request)

      conn = get(conn, Routes.requests_path(conn, :index), params)

      response = conn |> json_response(200)
      assert response["total_entries"] == 3
    end

    test "fails if invalid token in authorization header", context do
      %{conn: conn} = context
      bad_access_token = "qwerty1234567qwerty"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = get(conn, Routes.requests_path(conn, :index), %{})

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
