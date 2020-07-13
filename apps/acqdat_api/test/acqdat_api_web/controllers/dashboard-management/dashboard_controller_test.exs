defmodule AcqdatApiWeb.DashboardManagement.DashboardControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "show/2" do
    setup :setup_conn

    setup do
      dashboard = insert(:dashboard)

      [dashboard: dashboard]
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        id: 3
      }

      conn = get(conn, Routes.dashboard_path(conn, :show, 1, 1, params.id))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "dashboard with invalid dashboard id", %{conn: conn, dashboard: dashboard} do
      params = %{
        id: -1
      }

      conn =
        get(
          conn,
          Routes.dashboard_path(conn, :show, dashboard.org_id, dashboard.project_id, params.id)
        )

      result = conn |> json_response(400)
      assert result == %{"errors" => %{"message" => "dashboard with this id not found"}}
    end

    test "dashboard with valid id", %{conn: conn, dashboard: dashboard} do
      conn =
        get(
          conn,
          Routes.dashboard_path(conn, :show, dashboard.org_id, dashboard.project_id, dashboard.id)
        )

      result = conn |> json_response(200)

      refute is_nil(result)

      assert Map.has_key?(result, "id")
      assert Map.has_key?(result, "name")
    end
  end

  describe "create/2" do
    setup :setup_conn

    test "dashboard type create", %{conn: conn} do
      dashboard_manifest = build(:dashboard)
      project = insert(:project)

      data = %{
        name: dashboard_manifest.name
      }

      conn = post(conn, Routes.dashboard_path(conn, :create, project.org_id, project.id), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end

    test "fails if authorization header not found", %{conn: conn} do
      bad_access_token = "qwerty1234567uiop"
      project = insert(:project)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.dashboard_path(conn, :create, project.org_id, project.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if required params are missing", %{conn: conn} do
      project = insert(:project)

      data = %{}

      conn = post(conn, Routes.dashboard_path(conn, :create, project.org_id, project.id), data)

      response = conn |> json_response(400)

      assert response == %{
               "errors" => %{
                 "message" => %{
                   "name" => ["can't be blank"]
                 }
               }
             }
    end
  end

  describe "index/2" do
    setup :setup_conn

    test "fetch all dashboards", %{conn: conn} do
      dashboard = insert(:dashboard)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn =
        get(
          conn,
          Routes.dashboard_path(conn, :index, dashboard.org_id, dashboard.project_id, params)
        )

      response = conn |> json_response(200)

      assert length(response["dashboards"]) == 1
      assertion_dashboard = List.first(response["dashboards"])
      assert assertion_dashboard["id"] == dashboard.id
      assert assertion_dashboard["name"] == dashboard.name
    end

    test "if params are missing", %{conn: conn} do
      dashboard = insert(:dashboard)

      conn =
        get(
          conn,
          Routes.dashboard_path(conn, :index, dashboard.org_id, dashboard.project_id, %{})
        )

      response = conn |> json_response(200)
      assert response["total_pages"] == 1
      assert length(response["dashboards"]) == response["total_entries"]
    end

    test "Pagination", %{conn: conn} do
      dashboard = insert(:dashboard)

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn =
        get(
          conn,
          Routes.dashboard_path(conn, :index, dashboard.org_id, dashboard.project_id, params)
        )

      page1_response = conn |> json_response(200)
      assert page1_response["page_number"] == params["page_number"]
      assert page1_response["page_size"] == params["page_size"]
      assert page1_response["total_pages"] == 1
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"
      dashboard = insert(:dashboard)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn =
        get(
          conn,
          Routes.dashboard_path(conn, :index, dashboard.org_id, dashboard.project_id, params)
        )

      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end
end
