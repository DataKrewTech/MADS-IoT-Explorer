defmodule AcqdatApiWeb.ElasticSearch.UserControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Factory.ElasticSearch.User
  import AcqdatCore.Support.Factory

  describe "search_users/2" do
    setup :setup_conn

    setup do
      user = insert(:user)
      User.create_index()
      User.seed_user(user)
      :timer.sleep(5000)

      on_exit(fn ->
        User.delete_index()
      end)

      [new_user: user]
    end

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

    test "search with valid params", %{conn: conn, new_user: user} do
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

    setup do
      org = insert(:organisation)
      User.create_index()
      [user1, user2, user3] = User.seed_multiple_user(org, 3)
      :timer.sleep(5000)

      on_exit(fn ->
        User.delete_index()
      end)

      [user1: user1, user2: user2, user3: user3, new_org: org]
    end

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

    test "index with valid params and multiple entries", %{
      conn: conn,
      user1: user1,
      user2: user2,
      user3: user3,
      new_org: org
    } do
      conn =
        get(conn, Routes.user_path(conn, :index, user1.org_id), %{
          "from" => 0,
          "page_size" => 3
        })

      %{"users" => users} = conn |> json_response(200)

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
