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
      user = insert(:user)

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
      team = insert(:team)

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
