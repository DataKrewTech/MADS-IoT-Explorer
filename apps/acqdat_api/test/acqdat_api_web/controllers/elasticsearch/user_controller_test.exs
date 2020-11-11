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

    # test "search with valid params and indexing", %{conn: conn, user: user, org: org} do
    #   setup_index(%{user: user, org: org})

    #   conn =
    #     get(conn, Routes.user_path(conn, :search_users, user.org_id), %{
    #       "label" => user.first_name,
    #       "page_size" => 1,
    #       "from" => 0
    #     })

    #   result = conn |> json_response(200)

    #   role = %{
    #     "description" => user.role.description,
    #     "id" => user.role.id,
    #     "name" => user.role.name
    #   }

    #   organisation = %{"id" => user.org.id, "name" => user.org.name, "type" => "Organisation"}

    #   assert result == %{
    #            "users" => [
    #              %{
    #                "email" => user.email,
    #                "first_name" => user.first_name,
    #                "id" => user.id,
    #                "last_name" => user.last_name,
    #                "org_id" => user.org_id,
    #                "role_id" => user.role_id,
    #                "org" => organisation,
    #                "role" => role
    #              }
    #            ]
    #          }
    # end

    # test "search with no hits ", %{conn: conn, user: user, org: org} do
    #   setup_index(%{user: user, org: org})
    #   org = insert(:organisation)

    #   conn =
    #     get(conn, Routes.user_path(conn, :search_users, org.id), %{
    #       "label" => "Datakrew"
    #     })

    #   result = conn |> json_response(200)

    #   assert result == %{
    #            "users" => []
    #          }
    # end
  end
end
