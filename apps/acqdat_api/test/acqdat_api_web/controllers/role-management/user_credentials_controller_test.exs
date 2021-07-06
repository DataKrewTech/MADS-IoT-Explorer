defmodule AcqdatApiWeb.RoleManagement.UserCredentialsControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "update/2" do
    setup :setup_conn

    setup do
      user_credentials = insert(:user_credentials)

      [user_credentials: user_credentials]
    end

    test "user_credentials update successfully", context do
      %{user_credentials: user_credentials, conn: conn} = context

      conn =
        put(conn, Routes.user_credentials_path(conn, :update, user_credentials.id), %{
          "first_name" => "updated first_name",
          "last_name" => "updated last_name"
        })

      response = conn |> json_response(200)

      assert response["first_name"] == "updated first_name"
      assert response["last_name"] == "updated last_name"
    end

    test "fails if invalid token in authorization header", context do
      %{user_credentials: user_credentials, conn: conn} = context
      bad_access_token = "qwerty1234567qwerty"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = put(conn, Routes.user_credentials_path(conn, :update, user_credentials.id), %{})

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end
  end

  describe "show/2" do
    setup :setup_conn

    setup do
      user_credentials = insert(:user_credentials)

      [user_credentials: user_credentials]
    end

    test "shows user_credentials", context do
      %{user_credentials: user_credentials, conn: conn} = context

      conn = get(conn, Routes.user_credentials_path(conn, :show, user_credentials.id))

      response = conn |> json_response(200)

      assert response["id"] == user_credentials.id
    end

    test "fails if invalid user_credentials id is provided", context do
      %{conn: conn} = context

      conn = get(conn, Routes.user_credentials_path(conn, :show, -1))

      response = conn |> json_response(400)

      assert response == %{
               "detail" => "Either User or Organisation with this ID doesn't exists",
               "source" => nil,
               "status_code" => 400,
               "title" => "Invalid entity ID"
             }
    end

    test "fails if invalid token in authorization header", context do
      %{user_credentials: user_credentials, conn: conn} = context
      bad_access_token = "qwerty1234567qwerty"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = get(conn, Routes.user_credentials_path(conn, :show, user_credentials.id))

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
