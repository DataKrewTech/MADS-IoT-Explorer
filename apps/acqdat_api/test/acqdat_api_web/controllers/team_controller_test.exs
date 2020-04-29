defmodule AcqdatApiWeb.TeamControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)

      [org: org]
    end

    test "fails if authorization header not found", context do
      %{conn: conn, org: org} = context
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.team_path(conn, :create, org.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if required params are missing", context do
      %{conn: conn, org: org} = context
      conn = post(conn, Routes.team_path(conn, :create, org.id), %{"team" => %{}})

      response = conn |> json_response(400)

      assert response == %{"errors" => %{"message" => %{"name" => ["can't be blank"]}}}
    end

    test "team create", context do
      %{conn: conn, org: org} = context

      params = %{
        team: %{
          name: "Demo Team"
        }
      }

      conn = post(conn, Routes.team_path(conn, :create, org.id), params)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end
  end

  describe "update/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      user = insert(:user)
      team = insert(:team)

      [team: team, user: user, org: org]
    end

    test "fails if authorization header not found", context do
      %{team: team, org: org, conn: conn} = context

      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = put(conn, Routes.team_path(conn, :update, org.id, team.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "update team's team_lead", context do
      %{team: team, user: user, org: org, conn: conn} = context

      params = %{
        team: %{
          team_lead_id: user.id
        }
      }

      conn = put(conn, Routes.team_path(conn, :update, org.id, team.id), params)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end

    test "update team's description", context do
      %{team: team, org: org, conn: conn} = context

      params = %{
        team: %{
          description: "New updated Team description"
        }
      }

      conn = put(conn, Routes.team_path(conn, :update, org.id, team.id), params)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end

    test "update team's enable_tracking", context do
      %{team: team, org: org, conn: conn} = context

      params = %{
        team: %{
          enable_tracking: true
        }
      }

      conn = put(conn, Routes.team_path(conn, :update, org.id, team.id), params)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end
  end

  describe "assets/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      asset = insert(:asset)
      team = insert(:team)

      [team: team, asset: asset, org: org]
    end

    test "fails if authorization header not found", context do
      %{team: team, org: org, conn: conn} = context

      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}

      conn =
        put(conn, Routes.update_team_assets_path(conn, :update_assets, org.id, team.id), data)

      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if assets params are not present", context do
      %{team: team, org: org, conn: conn} = context

      params = %{
        team: %{}
      }

      conn =
        put(conn, Routes.update_team_assets_path(conn, :update_assets, org.id, team.id), params)

      response = conn |> json_response(400)
      assert response == %{"errors" => %{"message" => %{"assets" => ["can't be blank"]}}}
    end

    test "update team's assets", context do
      %{team: team, asset: asset, org: org, conn: conn} = context

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

      conn =
        put(conn, Routes.update_team_assets_path(conn, :update_assets, org.id, team.id), params)

      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end
  end

  describe "apps/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      app = insert(:app)
      team = insert(:team)

      [team: team, app: app, org: org]
    end

    test "fails if authorization header not found", context do
      %{team: team, org: org, conn: conn} = context

      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = put(conn, Routes.update_team_apps_path(conn, :update_apps, org.id, team.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if assets params are not present", context do
      %{team: team, org: org, conn: conn} = context

      params = %{
        team: %{}
      }

      conn = put(conn, Routes.update_team_apps_path(conn, :update_apps, org.id, team.id), params)
      response = conn |> json_response(400)
      assert response == %{"errors" => %{"message" => %{"apps" => ["can't be blank"]}}}
    end

    test "update team's apps", context do
      %{team: team, org: org, app: app, conn: conn} = context

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

      conn = put(conn, Routes.update_team_apps_path(conn, :update_apps, org.id, team.id), params)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end
  end

  describe "members/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      member = insert(:user)
      team = insert(:team)

      [team: team, member: member, org: org]
    end

    test "fails if authorization header not found", context do
      %{team: team, org: org, conn: conn} = context

      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}

      conn =
        put(conn, Routes.update_team_members_path(conn, :update_members, org.id, team.id), data)

      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if members params are not present", context do
      %{team: team, org: org, conn: conn} = context

      params = %{
        team: %{}
      }

      conn =
        put(conn, Routes.update_team_members_path(conn, :update_members, org.id, team.id), params)

      response = conn |> json_response(400)
      assert response == %{"errors" => %{"message" => %{"members" => ["can't be blank"]}}}
    end

    test "update team's members", context do
      %{team: team, org: org, member: member, conn: conn} = context

      params = %{
        team: %{
          members: [
            %{
              id: member.id
            }
          ]
        }
      }

      conn =
        put(conn, Routes.update_team_members_path(conn, :update_members, org.id, team.id), params)

      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end
  end

  describe "index/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)

      [org: org]
    end

    test "fails if authorization header not found", context do
      %{org: org, conn: conn} = context
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.team_path(conn, :create, org.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "team index", %{conn: conn} do
      team = insert(:team)

      params = %{
        page_size: 10,
        page_number: 1
      }

      conn = get(conn, Routes.team_path(conn, :index, team.org_id), params)
      response = conn |> json_response(200)
      assert response["total_entries"] == 1
    end
  end
end
