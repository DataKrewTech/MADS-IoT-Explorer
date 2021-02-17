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

      conn = get(conn, Routes.dashboard_path(conn, :show, 1, params.id))
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "dashboard with invalid dashboard id", %{conn: conn, dashboard: dashboard} do
      params = %{
        id: -1
      }

      conn =
        get(
          conn,
          Routes.dashboard_path(conn, :show, dashboard.org_id, params.id)
        )

      result = conn |> json_response(404)

      assert result == %{
               "detail" => "Dashboard with this ID does not exists",
               "source" => nil,
               "status_code" => 404,
               "title" => "Invalid entity ID"
             }
    end

    test "dashboard with valid id", %{conn: conn, dashboard: dashboard} do
      conn =
        get(
          conn,
          Routes.dashboard_path(conn, :show, dashboard.org_id, dashboard.id)
        )

      result = conn |> json_response(200)

      refute is_nil(result)

      assert Map.has_key?(result, "id")
      assert Map.has_key?(result, "name")
    end
  end

  describe "update/2" do
    setup :setup_conn

    setup do
      dashboard = insert(:dashboard)

      [dashboard: dashboard]
    end

    test "dashboard update", %{conn: conn, dashboard: dashboard} do
      data = %{
        name: "updated dashboard name"
      }

      conn =
        put(
          conn,
          Routes.dashboard_path(
            conn,
            :update,
            dashboard.org_id,
            dashboard.id
          ),
          data
        )

      response = conn |> json_response(200)

      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      assert response["name"] == "updated dashboard name"
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        id: 3
      }

      conn = put(conn, Routes.dashboard_path(conn, :update, 1, params.id))
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "dashboard with invalid dashboard id", %{conn: conn, dashboard: dashboard} do
      params = %{
        id: -1
      }

      conn =
        put(
          conn,
          Routes.dashboard_path(conn, :update, dashboard.org_id, params.id)
        )

      result = conn |> json_response(404)

      assert result == %{
               "detail" => "Dashboard with this ID does not exists",
               "source" => nil,
               "status_code" => 404,
               "title" => "Invalid entity ID"
             }
    end
  end

  describe "delete/2" do
    setup :setup_conn

    setup do
      dashboard = insert(:dashboard)

      [dashboard: dashboard]
    end

    test "dashboard delete", %{conn: conn, dashboard: dashboard} do
      conn =
        delete(
          conn,
          Routes.dashboard_path(
            conn,
            :delete,
            dashboard.org_id,
            dashboard.id
          )
        )

      response = conn |> json_response(200)

      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        id: 3
      }

      conn = delete(conn, Routes.dashboard_path(conn, :delete, 1, params.id))
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "dashboard with invalid dashboard id", %{conn: conn} do
      params = %{
        id: -1
      }

      conn = delete(conn, Routes.dashboard_path(conn, :delete, 1, params.id))

      result = conn |> json_response(404)

      assert result == %{
               "detail" => "Dashboard with this ID does not exists",
               "source" => nil,
               "status_code" => 404,
               "title" => "Invalid entity ID"
             }
    end
  end

  describe "create/2" do
    setup :setup_conn

    test "dashboard type create", %{conn: conn} do
      dashboard_manifest = build(:dashboard)
      org = insert(:organisation)

      data = %{
        name: dashboard_manifest.name
      }

      conn = post(conn, Routes.dashboard_path(conn, :create, org.id), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end

    test "fails if authorization header not found", %{conn: conn} do
      bad_access_token = "qwerty1234567uiop"
      org = insert(:organisation)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.dashboard_path(conn, :create, org.id), data)
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "fails if required params are missing", %{conn: conn} do
      org = insert(:organisation)

      data = %{}

      conn = post(conn, Routes.dashboard_path(conn, :create, org.id), data)

      response = conn |> json_response(400)

      assert response == %{
               "detail" =>
                 "Parameters provided to perform current action is either not valid or missing or not unique",
               "source" => %{"name" => ["can't be blank"]},
               "status_code" => 400,
               "title" => "Insufficient or not unique parameters"
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
          Routes.dashboard_path(conn, :index, dashboard.org_id, params)
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
          Routes.dashboard_path(conn, :index, dashboard.org_id, %{})
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
          Routes.dashboard_path(conn, :index, dashboard.org_id, params)
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
          Routes.dashboard_path(conn, :index, dashboard.org_id, params)
        )

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end
  end

  describe "archived/2" do
    setup :setup_conn

    test "fetch all archived dashboards", %{conn: conn} do
      insert_list(3, :dashboard)
      dashboard = insert(:dashboard, archived: true)

      params = %{
        "page_size" => 100,
        "page_number" => 1,
        "type" => "archived"
      }

      conn =
        get(
          conn,
          Routes.dashboard_path(conn, :index, dashboard.org_id, params)
        )

      response = conn |> json_response(200)

      assert length(response["dashboards"]) == 1
      assertion_dashboard = List.first(response["dashboards"])
      assert assertion_dashboard["id"] == dashboard.id
      assert assertion_dashboard["name"] == dashboard.name
    end

    test "if params are missing", %{conn: conn} do
      dashboard = insert(:dashboard, archived: true)

      conn =
        get(
          conn,
          Routes.dashboard_path(conn, :index, dashboard.org_id, %{})
        )

      response = conn |> json_response(200)
      assert response["total_pages"] == 1
      assert length(response["dashboards"]) == response["total_entries"]
    end

    test "Pagination", %{conn: conn} do
      dashboard = insert(:dashboard, archived: true)

      params = %{
        "page_size" => 2,
        "page_number" => 1,
        "type" => "archived"
      }

      conn =
        get(
          conn,
          Routes.dashboard_path(conn, :index, dashboard.org_id, params)
        )

      page1_response = conn |> json_response(200)
      assert page1_response["page_number"] == params["page_number"]
      assert page1_response["page_size"] == params["page_size"]
      assert page1_response["total_pages"] == 1
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"
      dashboard = insert(:dashboard, archived: true)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        "page_size" => 2,
        "page_number" => 1,
        "type" => "archived"
      }

      conn =
        get(
          conn,
          Routes.dashboard_path(conn, :index, dashboard.org_id, params)
        )

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end
  end

  describe "recent dashboards/2" do
    setup :setup_conn

    setup do
      dashboard = insert(:dashboard)

      [dashboard: dashboard]
    end

    test "fails if invalid token in authorization header", %{conn: conn, dashboard: dashboard} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        "page_size" => 2,
        "page_number" => 1,
        "type" => "archived"
      }

      conn =
        get(
          conn,
          Routes.dashboard_path(conn, :recent_dashboard, dashboard.org_id, params)
        )

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "recent dashboard with valid dashboard id", %{
      conn: conn,
      dashboard: dashboard,
      user: user
    } do
      get(
        conn,
        Routes.dashboard_path(conn, :show, dashboard.org_id, dashboard.id)
      )

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn =
        get(
          conn,
          Routes.dashboard_path(conn, :recent_dashboard, dashboard.org_id, params)
        )

      %{"dashboards" => [rdashboard]} = conn |> json_response(200)
      assert rdashboard["id"] == dashboard.id
    end
  end
end
