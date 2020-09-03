defmodule AcqdatApiWeb.DashboardManagement.PanelControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "show/2" do
    setup :setup_conn

    setup do
      panel = insert(:panel)

      [panel: panel]
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        id: 3
      }

      conn = get(conn, Routes.panel_path(conn, :show, 1, 1, params.id))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "panel with invalid panel id", %{conn: conn, panel: panel} do
      params = %{
        id: -1
      }

      conn =
        get(
          conn,
          Routes.panel_path(conn, :show, panel.org_id, panel.dashboard_id, params.id)
        )

      result = conn |> json_response(400)
      assert result == %{"errors" => %{"message" => "panel with this id not found"}}
    end

    test "panel with valid id", %{conn: conn, panel: panel} do
      conn =
        get(
          conn,
          Routes.panel_path(conn, :show, panel.org_id, panel.dashboard_id, panel.id)
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
      panel = insert(:panel)

      [panel: panel]
    end

    test "panel update", %{conn: conn, panel: panel} do
      data = %{
        name: "updated panel name"
      }

      conn =
        put(
          conn,
          Routes.panel_path(
            conn,
            :update,
            panel.org_id,
            panel.dashboard_id,
            panel.id
          ),
          data
        )

      response = conn |> json_response(200)

      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      assert response["name"] == "updated panel name"
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        id: 3
      }

      conn = put(conn, Routes.panel_path(conn, :update, 1, 1, params.id))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "panel with invalid panel id", %{conn: conn, panel: panel} do
      params = %{
        id: -1
      }

      conn =
        put(
          conn,
          Routes.panel_path(conn, :update, panel.org_id, panel.dashboard_id, params.id)
        )

      result = conn |> json_response(404)
      assert result == %{"errors" => %{"message" => "Resource Not Found"}}
    end
  end

  describe "delete/2" do
    setup :setup_conn

    setup do
      panel = insert(:panel)

      [panel: panel]
    end

    test "panel delete", %{conn: conn, panel: panel} do
      params = %{
        id: panel.id
      }

      conn =
        delete(
          conn,
          Routes.panel_path(
            conn,
            :delete,
            panel.org_id,
            panel.dashboard_id,
            params.id
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
        id: 1
      }

      conn = delete(conn, Routes.panel_path(conn, :delete, 1, 1, params.id))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "panel with invalid panel id", %{conn: conn, panel: panel} do
      params = %{
        id: -1
      }

      conn = delete(conn, Routes.panel_path(conn, :delete, 1, panel.dashboard_id, params.id))

      result = conn |> json_response(404)
      assert result == %{"errors" => %{"message" => "Resource Not Found"}}
    end
  end

  describe "create/2" do
    setup :setup_conn

    test "panel type create", %{conn: conn} do
      panel_manifest = build(:panel)
      org = insert(:organisation)
      dashboard = insert(:dashboard)

      data = %{
        name: panel_manifest.name
      }

      conn = post(conn, Routes.panel_path(conn, :create, org.id, dashboard.id), data)
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
      conn = post(conn, Routes.panel_path(conn, :create, org.id, 1), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if required params are missing", %{conn: conn} do
      org = insert(:organisation)
      dashboard = insert(:dashboard)

      data = %{}

      conn = post(conn, Routes.panel_path(conn, :create, org.id, dashboard.id), data)

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

    test "fetch all panels", %{conn: conn} do
      panel = insert(:panel)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn =
        get(
          conn,
          Routes.panel_path(conn, :index, panel.org_id, panel.dashboard_id, params)
        )

      response = conn |> json_response(200)

      assert length(response["panels"]) == 1
      assertion_panel = List.first(response["panels"])
      assert assertion_panel["id"] == panel.id
      assert assertion_panel["name"] == panel.name
    end

    test "if params are missing", %{conn: conn} do
      panel = insert(:panel)

      conn =
        get(
          conn,
          Routes.panel_path(conn, :index, panel.org_id, panel.dashboard_id, %{})
        )

      response = conn |> json_response(200)
      assert response["total_pages"] == 1
      assert length(response["panels"]) == response["total_entries"]
    end

    test "Pagination", %{conn: conn} do
      panel = insert(:panel)

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn =
        get(
          conn,
          Routes.panel_path(conn, :index, panel.org_id, panel.dashboard_id, params)
        )

      page1_response = conn |> json_response(200)
      assert page1_response["page_number"] == params["page_number"]
      assert page1_response["page_size"] == params["page_size"]
      assert page1_response["total_pages"] == 1
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"
      panel = insert(:panel)

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
          Routes.panel_path(conn, :index, panel.org_id, panel.dashboard_id, params)
        )

      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end
end
