defmodule AcqdatApiWeb.ElasticSearch.UserControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Factory.ElasticSearch.User
  import AcqdatCore.Support.Factory

  describe "search_users/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn, user: user, org: org} do
      User.create_index()
      User.seed_user(user)
      bad_access_token = "avcbd123489u"
      org = insert(:organisation)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(conn, Routes.user_path(conn, :search_users, org.id), %{
          "label" => "Chandu"
        })

      result = conn |> json_response(403)
      User.delete_index()
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "search with valid params", %{conn: conn, user: user, org: org} do
      User.create_index()
      User.seed_user(user)
      :timer.sleep(1500)

      conn =
        get(conn, Routes.user_path(conn, :search_users, user.org_id), %{
          "label" => user.first_name
        })

      result = conn |> json_response(200)

      role = %{
        "description" => user.role.description,
        "id" => user.role.id,
        "name" => user.role.name
      }

      organisation = %{"id" => user.org.id, "name" => user.org.name, "type" => "Organisation"}
      User.delete_index()

      assert result == %{
               "users" => [
                 %{
                   "email" => user.email,
                   "first_name" => user.first_name,
                   "id" => user.id,
                   "last_name" => user.last_name,
                   "org_id" => user.org_id,
                   "role_id" => user.role_id,
                   "org" => organisation,
                   "role" => role
                 }
               ]
             }
    end

    test "search with no hits in a particular organisation", %{conn: conn, user: user, org: org} do
      User.create_index()
      User.seed_user(user)
      :timer.sleep(1500)
      org = insert(:organisation)

      conn =
        get(conn, Routes.user_path(conn, :search_users, org.id), %{
          "label" => user.first_name
        })

      result = conn |> json_response(200)

      assert result == %{
               "users" => []
             }
    end
  end

  describe "index users/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn, user: user, org: org} do
      User.create_index()
      [user1, user2, user3] = User.seed_multiple_user(org)
      :timer.sleep(1500)
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(conn, Routes.user_path(conn, :index, org.id), %{
          "from" => 0,
          "page_size" => 1
        })

      result = conn |> json_response(403)
      User.delete_index()
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "index with valid params and multiple entries", %{conn: conn, user: user, org: org} do
      User.create_index()
      [user1, user2, user3] = User.seed_multiple_user(org)
      :timer.sleep(1500)

      conn =
        get(conn, Routes.user_path(conn, :index, user1.org_id), %{
          "from" => 0,
          "page_size" => 3
        })

      %{"users" => users} = conn |> json_response(200)

      User.delete_index()
      assert length(users) == 3
      [ruser1, ruser2, ruser3] = users
      assert ruser1["email"] == user1.email
      assert ruser1["first_name"] == user1.first_name
      assert ruser1["id"] == user1.id
      assert ruser2["email"] == user2.email
      assert ruser2["first_name"] == user2.first_name
      assert ruser2["id"] == user2.id
      assert ruser3["email"] == user3.email
      assert ruser3["first_name"] == user3.first_name
      assert ruser3["id"] == user3.id
    end
  end
end
