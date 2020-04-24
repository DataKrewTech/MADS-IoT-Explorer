defmodule AcqdatApiWeb.TeamControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn} do
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.team_path(conn, :create), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if required params are missing", %{conn: conn} do
      conn = post(conn, Routes.team_path(conn, :create), %{"team" => %{}})

      response = conn |> json_response(400)

      assert response == %{"errors" => %{"message" => %{"name" => ["can't be blank"]}}}
    end

    test "team create", %{conn: conn} do
      org = insert(:organisation)

      params = %{
        team: %{
          name: "Demo Team",
          org_id: org.id
        }
      }

      conn = post(conn, Routes.team_path(conn, :create), params)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end
  end

  describe "update/2" do
    setup :setup_conn

    setup do
      user = insert(:user)
      team = insert(:team)

      [team: team, user: user]
    end

    test "fails if authorization header not found", context do
      %{team: team, conn: conn} = context

      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = put(conn, Routes.team_path(conn, :update, team.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "update team's team_lead", context do
      %{team: team, user: user, conn: conn} = context

      params = %{
        team: %{
          team_lead_id: user.id
        }
      }

      conn = put(conn, Routes.team_path(conn, :update, team.id), params)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end

    test "update team's description", context do
      %{team: team, conn: conn} = context

      params = %{
        team: %{
          description: "New updated Team description"
        }
      }

      conn = put(conn, Routes.team_path(conn, :update, team.id), params)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end

    test "update team's enable_tracking", context do
      %{team: team, conn: conn} = context

      params = %{
        team: %{
          enable_tracking: true
        }
      }

      conn = put(conn, Routes.team_path(conn, :update, team.id), params)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end
  end

  describe "assets/2" do
    setup :setup_conn

    setup do
      asset = insert(:asset)
      team = insert(:team)

      [team: team, asset: asset]
    end

    test "fails if authorization header not found", context do
      %{team: team, conn: conn} = context

      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = put(conn, Routes.update_team_assets_path(conn, :assets, team.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if assets params are not present", context do
      %{team: team, conn: conn} = context

      params = %{
        team: %{}
      }

      conn = put(conn, Routes.update_team_assets_path(conn, :assets, team.id), params)
      response = conn |> json_response(400)
      assert response == %{"errors" => %{"message" => %{"assets" => ["can't be blank"]}}}
    end

    test "update team's assets", context do
      %{team: team, asset: asset, conn: conn} = context

      params = %{
        team: %{
          assets: [
            %{
              id: asset.id,
              name: asset.name
            }
          ]
        }
      }

      conn = put(conn, Routes.update_team_assets_path(conn, :assets, team.id), params)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end
  end

  describe "apps/2" do
    setup :setup_conn

    setup do
      app = insert(:app)
      team = insert(:team)

      [team: team, app: app]
    end

    test "fails if authorization header not found", context do
      %{team: team, conn: conn} = context

      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = put(conn, Routes.update_team_apps_path(conn, :apps, team.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if assets params are not present", context do
      %{team: team, conn: conn} = context

      params = %{
        team: %{}
      }

      conn = put(conn, Routes.update_team_apps_path(conn, :apps, team.id), params)
      response = conn |> json_response(400)
      assert response == %{"errors" => %{"message" => %{"apps" => ["can't be blank"]}}}
    end

    test "update team's apps", context do
      %{team: team, app: app, conn: conn} = context

      params = %{
        team: %{
          apps: [
            %{
              id: app.id,
              name: app.name
            }
          ]
        }
      }

      conn = put(conn, Routes.update_team_apps_path(conn, :apps, team.id), params)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end
  end

  describe "members/2" do
    setup :setup_conn

    setup do
      member = insert(:user)
      team = insert(:team)

      [team: team, member: member]
    end

    test "fails if authorization header not found", context do
      %{team: team, conn: conn} = context

      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = put(conn, Routes.update_team_members_path(conn, :members, team.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if members params are not present", context do
      %{team: team, conn: conn} = context

      params = %{
        team: %{}
      }

      conn = put(conn, Routes.update_team_members_path(conn, :members, team.id), params)
      response = conn |> json_response(400)
      assert response == %{"errors" => %{"message" => %{"members" => ["can't be blank"]}}}
    end

    test "update team's members", context do
      %{team: team, member: member, conn: conn} = context

      params = %{
        team: %{
          members: [
            %{
              id: member.id
            }
          ]
        }
      }

      conn = put(conn, Routes.update_team_members_path(conn, :members, team.id), params)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end
  end

  describe "index/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn} do
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.team_path(conn, :create), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "team index", %{conn: conn} do
      insert(:team)

      params = %{
        page_size: 10,
        page_number: 1
      }

      conn = get(conn, Routes.team_path(conn, :index), params)
      response = conn |> json_response(200)
      assert response["total_entries"] == 1
    end
  end
end
