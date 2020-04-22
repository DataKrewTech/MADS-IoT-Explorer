defmodule AcqdatApiWeb.UserControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "show/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn} do
      bad_access_token = "avcbd123489u"
      org = insert(:organisation)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = get(conn, Routes.organisation_user_path(conn, :show, org.id, 1))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "user with invalid organisation id", %{conn: conn, user: user} do
      org = insert(:organisation)

      conn = get(conn, Routes.organisation_user_path(conn, :show, org.id, -1))
      result = conn |> json_response(404)
      assert result == %{"errors" => %{"message" => "Resource Not Found"}}
    end

    test "user with valid id", %{conn: conn, user: user} do
      conn = get(conn, Routes.organisation_user_path(conn, :show, user.org_id, user.id))
      result = conn |> json_response(200)

      assert result["id"] == user.id
    end
  end

  describe "search_users/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn} do
      bad_access_token = "avcbd123489u"
      org = insert(:organisation)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(conn, Routes.organisation_user_path(conn, :search_users, org.id), %{
          "label" => "Chandu"
        })

      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    # test "search with valid params", %{conn: conn, user: user} do
    #   conn =
    #     get(conn, Routes.organisation_user_path(conn, :search_users, user.org_id), %{
    #       "label" => "Chandu"
    #     })

    #   result = conn |> json_response(200)   
    #   assert result = %{
    #            "users" => [
    #              %{
    #                "email" => "chandu@stack-avenue.com",
    #                "first_name" => "Chandu",
    #                "id" => 1,
    #                "last_name" => "Developer",
    #                "org_id" => 1
    #              }
    #            ]
    #          }
    # end

    test "search with no hits ", %{conn: conn} do
      org = insert(:organisation)

      conn =
        get(conn, Routes.organisation_user_path(conn, :search_users, org.id), %{
          "label" => "Datakrew"
        })

      result = conn |> json_response(200)

      assert result = %{
               "users" => []
             }
    end
  end
end
