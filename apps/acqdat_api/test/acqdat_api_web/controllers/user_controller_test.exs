defmodule AcqdatApiWeb.UserControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "show/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn, org: org} do
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = get(conn, Routes.user_path(conn, :show, org.id, 1))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "user with invalid organisation id", %{conn: conn, user: _user, org: org} do
      conn = get(conn, Routes.user_path(conn, :show, org.id, -1))
      result = conn |> json_response(404)
      assert result == %{"errors" => %{"message" => "Resource Not Found"}}
    end

    test "user with valid id", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user.org_id, user.id))
      result = conn |> json_response(200)

      assert result["id"] == user.id
    end
  end

  describe "assets/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      asset = insert(:asset)
      user = insert(:user)

      [user: user, asset: asset, org: org]
    end

    test "fails if authorization header not found", context do
      %{user: user, conn: conn, org: org} = context

      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = put(conn, Routes.user_assets_path(conn, :assets, org.id, user.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if assets params are not present", context do
      %{user: user, conn: conn, org: org} = context

      params = %{}

      conn = put(conn, Routes.user_assets_path(conn, :assets, org.id, user.id), params)
      response = conn |> json_response(400)
      assert response == %{"errors" => %{"message" => %{"assets" => ["can't be blank"]}}}
    end

    test "update user's assets", context do
      %{user: user, asset: asset, conn: conn, org: org} = context

      params = %{
        assets: [
          %{
            id: asset.id,
            name: asset.name
          }
        ]
      }

      conn = put(conn, Routes.user_assets_path(conn, :assets, org.id, user.id), params)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "assets")
    end
  end

  describe "apps/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      app = insert(:app)
      user = insert(:user)

      [user: user, app: app, org: org]
    end

    test "fails if authorization header not found", context do
      %{user: user, conn: conn, org: org} = context

      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = put(conn, Routes.user_apps_path(conn, :apps, org.id, user.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if assets params are not present", context do
      %{user: user, conn: conn, org: org} = context

      params = %{}

      conn = put(conn, Routes.user_apps_path(conn, :apps, org.id, user.id), params)
      response = conn |> json_response(400)
      assert response == %{"errors" => %{"message" => %{"apps" => ["can't be blank"]}}}
    end

    test "update user's apps", context do
      %{user: user, app: app, conn: conn, org: org} = context

      params = %{
        apps: [
          %{
            id: app.id,
            name: app.name
          }
        ]
      }

      conn = put(conn, Routes.user_apps_path(conn, :apps, org.id, user.id), params)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "apps")
    end
  end

  describe "create/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      invitation = insert(:invitation)
      [org: org, invitation: invitation]
    end

    test "fails if invitation-token header not found", context do
      %{org: org, conn: conn} = context

      bad_invitation_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("invitation-token", bad_invitation_token)

      data = %{
        user: %{
          password: "test123@!%$",
          password_confirmation: "test123@!%$",
          first_name: "Demo Name"
        }
      }

      conn = post(conn, Routes.user_path(conn, :create, org.id), data)
      result = conn |> json_response(400)

      result[:errors] == %{message: %{error: "Invitation doesn't exist"}}
    end

    test "user create when valid token", context do
      %{org: org, invitation: invitation, conn: conn} = context

      data = %{
        user: %{
          password: "test123@!%$",
          password_confirmation: "test123@!%$",
          first_name: "Demo Name"
        }
      }

      conn =
        conn
        |> put_req_header("invitation-token", invitation.token)

      conn = post(conn, Routes.user_path(conn, :create, org.id), data)

      response = conn |> json_response(200)
      assert Map.has_key?(response, "is_invited")
      assert response["is_invited"]
      assert response["first_name"] == "Demo Name"
    end
  end

  # describe "search_users/2" do
  #   setup :setup_conn

  #   test "fails if authorization header not found", %{conn: conn} do
  #     bad_access_token = "avcbd123489u"
  #     org = insert(:organisation)

  #     conn =
  #       conn
  #       |> put_req_header("authorization", "Bearer #{bad_access_token}")

  #     conn =
  #       get(conn, Routes.organisation_user_path(conn, :search_users, org.id), %{
  #         "label" => "Chandu"
  #       })

  #     result = conn |> json_response(403)
  #     assert result == %{"errors" => %{"message" => "Unauthorized"}}
  #   end

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

  #   test "search with no hits ", %{conn: conn} do
  #     org = insert(:organisation)

  #     conn =
  #       get(conn, Routes.organisation_user_path(conn, :search_users, org.id), %{
  #         "label" => "Datakrew"
  #       })

  #     result = conn |> json_response(200)

  #     assert result = %{
  #              "users" => []
  #            }
  #   end
  # end
end
