defmodule AcqdatApiWeb.ElasticSearch.UserControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Factory.ElasticSearch.User
  import AcqdatCore.Support.Factory

  describe "search_users/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn, user: user} do
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
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "search with valid params", %{conn: conn, user: user} do
      User.create_index()
      User.seed_user(user)
      :timer.sleep(2500)

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
                   "role_id" => user.role_id,
                   "org" => organisation,
                   "role" => role,
                   "image" => nil,
                   "is_invited" => false,
                   "phone_number" => nil,
                   "user_setting" => nil
                 }
               ],
               "total_entries" => 1
             }
    end

    test "search with no hits in a particular organisation", %{conn: conn, user: user} do
      User.create_index()
      User.seed_user(user)
      :timer.sleep(2500)
      org = insert(:organisation)

      conn =
        get(conn, Routes.user_path(conn, :search_users, org.id), %{
          "label" => user.first_name
        })

      result = conn |> json_response(200)

      assert result == %{
               "users" => [],
               "total_entries" => 0
             }
    end
  end

  describe "index users/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn, org: org} do
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
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "index with valid params and multiple entries", %{conn: conn, org: org} do
      User.create_index()
      [user1, user2, user3] = User.seed_multiple_user(org)
      :timer.sleep(2500)

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

  describe "update and delete users/2" do
    setup :setup_conn

    test "if user is updated", %{conn: conn, user: user} do
      User.create_index()
      User.seed_user(user)
      :timer.sleep(2500)

      conn =
        put(conn, Routes.user_path(conn, :update, user.org_id, user.id), %{
          "first_name" => "Random User"
        })

      :timer.sleep(2500)

      conn =
        get(conn, Routes.user_path(conn, :search_users, user.org_id), %{
          "label" => "Random User"
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
                   "first_name" => "Random User",
                   "id" => user.id,
                   "last_name" => user.last_name,
                   "role_id" => user.role_id,
                   "org" => organisation,
                   "role" => role,
                   "image" => nil,
                   "is_invited" => false,
                   "phone_number" => nil,
                   "user_setting" => nil
                 }
               ],
               "total_entries" => 1
             }
    end

    test "if user is deleted", %{conn: conn, user: user} do
      User.create_index()
      User.seed_user(user)
      :timer.sleep(2500)

      conn = delete(conn, Routes.user_path(conn, :delete, user.org_id, user.id))

      :timer.sleep(2500)

      conn =
        get(conn, Routes.user_path(conn, :search_users, user.org_id), %{
          "label" => user.first_name
        })

      result = conn |> json_response(200)
      User.delete_index()

      assert result == %{
               "users" => [],
               "total_entries" => 0
             }
    end

    test "if user is deleted check for multiple users", %{conn: conn, org: org} do
      User.create_index()
      [user1, user2, _user3] = User.seed_multiple_user(org)
      :timer.sleep(2500)

      conn = delete(conn, Routes.user_path(conn, :delete, user1.org_id, user1.id))

      :timer.sleep(2500)

      conn =
        get(conn, Routes.user_path(conn, :search_users, user2.org_id), %{
          "label" => user2.first_name
        })

      result = conn |> json_response(200)

      role = %{
        "description" => user2.role.description,
        "id" => user2.role.id,
        "name" => user2.role.name
      }

      organisation = %{"id" => user2.org.id, "name" => user2.org.name, "type" => "Organisation"}
      User.delete_index()

      assert result == %{
               "users" => [
                 %{
                   "email" => user2.email,
                   "first_name" => user2.first_name,
                   "id" => user2.id,
                   "last_name" => user2.last_name,
                   "role_id" => user2.role_id,
                   "org" => organisation,
                   "role" => role,
                   "image" => nil,
                   "is_invited" => false,
                   "phone_number" => nil,
                   "user_setting" => nil
                 }
               ],
               "total_entries" => 1
             }
    end
  end
end
