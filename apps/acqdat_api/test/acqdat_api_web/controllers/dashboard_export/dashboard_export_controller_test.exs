defmodule AcqdatApiWeb.DashboardExport.DashboardExportControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.DashboardManagement.Schema.Dashboard
  alias AcqdatCore.Model.DashboardExport.DashboardExport, as: DashboardExportModel
  alias AcqdatCore.Repo
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_conn

    setup do
      dashboard = insert(:dashboard)

      [dashboard: dashboard]
    end

    test "create exported url publicly", %{conn: conn, org: org, dashboard: dashboard} do
      data = %{is_secure: false}
      conn = post(conn, Routes.dashboard_export_path(conn, :create, org.id, dashboard.id), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "url")
    end

    test "create exported url privately", %{conn: conn, org: org, dashboard: dashboard} do
      data = %{is_secure: true, password: "mads@1234"}
      conn = post(conn, Routes.dashboard_export_path(conn, :create, org.id, dashboard.id), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "url")
    end

    test "create private exported without password", %{conn: conn, org: org, dashboard: dashboard} do
      data = %{is_secure: true}
      conn = post(conn, Routes.dashboard_export_path(conn, :create, org.id, dashboard.id), data)
      result = conn |> json_response(400)

      assert %{
               "detail" =>
                 "Parameters provided to perform current action is either not valid or missing or not unique",
               "source" => %{"password" => ["can't be blank"]},
               "status_code" => 400,
               "title" => "Insufficient or not unique parameters"
             } == result
    end
  end

  describe "update/2" do
    setup :setup_conn

    setup do
      dashboard = insert(:dashboard)

      [dashboard: dashboard]
    end

    test "update private exported dashboard to public", %{
      conn: conn,
      org: org,
      dashboard: dashboard
    } do
      private_dashboard_exp = insert(:dashboard_export, is_secure: true, password: "test123")
      data = %{is_secure: false}

      conn =
        put(
          conn,
          Routes.dashboard_export_path(
            conn,
            :update,
            org.id,
            dashboard.id,
            private_dashboard_exp.dashboard_uuid
          ),
          data
        )

      response = conn |> json_response(200)

      assert Map.has_key?(response, "is_secure")
      assert response["is_secure"] == false
    end

    test "update public exported dashboard to private", %{
      conn: conn,
      org: org,
      dashboard: dashboard
    } do
      private_dashboard_exp = insert(:dashboard_export, is_secure: false)
      data = %{is_secure: true, password: "test123"}

      conn =
        put(
          conn,
          Routes.dashboard_export_path(
            conn,
            :update,
            org.id,
            dashboard.id,
            private_dashboard_exp.dashboard_uuid
          ),
          data
        )

      response = conn |> json_response(200)

      assert Map.has_key?(response, "is_secure")
      assert response["is_secure"] == true
    end

    test "update public exported dashboard to private will fail if password is not provided", %{
      conn: conn,
      org: org,
      dashboard: dashboard
    } do
      private_dashboard_exp = insert(:dashboard_export, is_secure: false)
      data = %{is_secure: true}

      conn =
        put(
          conn,
          Routes.dashboard_export_path(
            conn,
            :update,
            org.id,
            dashboard.id,
            private_dashboard_exp.dashboard_uuid
          ),
          data
        )

      response = conn |> json_response(400)

      assert response == %{
               "detail" =>
                 "Parameters provided to perform current action is either not valid or missing or not unique",
               "source" => %{"password" => ["can't be blank"]},
               "status_code" => 400,
               "title" => "Insufficient or not unique parameters"
             }
    end
  end

  describe "show_credentials/2" do
    setup :setup_conn

    setup do
      dashboard = insert(:dashboard)

      [dashboard: dashboard]
    end

    test "shows credentials of the private dashboard_export", %{
      conn: conn,
      org: org,
      dashboard: dashboard
    } do
      private_dashboard_exp = insert(:dashboard_export, is_secure: true, password: "test123")

      conn =
        get(
          conn,
          Routes.dashboard_export_path(
            conn,
            :show_credentials,
            org.id,
            dashboard.id,
            private_dashboard_exp.dashboard_uuid
          )
        )

      response = conn |> json_response(200)

      assert Map.has_key?(response, "password")
      assert response["is_secure"] == true
      assert response["password"] == "test123"
    end

    test "credentials of public dashboard_export'll be null", %{
      conn: conn,
      org: org,
      dashboard: dashboard
    } do
      private_dashboard_exp = insert(:dashboard_export, is_secure: false)

      conn =
        get(
          conn,
          Routes.dashboard_export_path(
            conn,
            :show_credentials,
            org.id,
            dashboard.id,
            private_dashboard_exp.dashboard_uuid
          )
        )

      response = conn |> json_response(200)

      assert Map.has_key?(response, "password")
      assert response["is_secure"] == false
      refute response["password"]
    end

    test "it'll show error if dashboard_export doesn't exist", %{
      conn: conn,
      org: org,
      dashboard: dashboard
    } do
      conn =
        get(
          conn,
          Routes.dashboard_export_path(
            conn,
            :show_credentials,
            org.id,
            dashboard.id,
            -1
          )
        )

      response = conn |> json_response(404)

      assert response == %{
               "detail" => "Resource with this ID does not exists",
               "source" => nil,
               "status_code" => 404,
               "title" => "Invalid entity ID"
             }
    end
  end

  describe "show/2" do
    setup :setup_conn

    setup do
      panel = insert(:panel)

      dashboard = Repo.get(Dashboard, panel.dashboard_id)

      {:ok, private_dashboard_exp} =
        DashboardExportModel.create(%{
          token: UUID.uuid1(:hex),
          is_secure: false,
          dashboard_id: panel.dashboard_id,
          dashboard_uuid: dashboard.uuid,
          url: "url"
        })

      [panel: panel, dashboard: dashboard, private_dashboard_exp: private_dashboard_exp]
    end

    test "fails if invalid token in authorization header", %{
      conn: conn,
      panel: panel,
      dashboard: dashboard
    } do
      conn =
        post(
          conn,
          Routes.dashboard_export_path(conn, :show, dashboard.uuid, panel.id)
        )

      result = conn |> json_response(401)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 401,
               "title" => "Unauthorized Access"
             }
    end

    test "panel with invalid panel id", %{
      conn: conn,
      dashboard: dashboard,
      private_dashboard_exp: private_dashboard_exp
    } do
      access_token = private_dashboard_exp.token

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{access_token}")

      conn =
        post(
          conn,
          Routes.dashboard_export_path(conn, :show, dashboard.uuid, -1)
        )

      result = conn |> json_response(404)

      assert result == %{
               "detail" => "Resource with this ID does not exists",
               "source" => nil,
               "status_code" => 404,
               "title" => "Invalid entity ID"
             }
    end

    test "panel with valid id", %{
      conn: conn,
      panel: panel,
      dashboard: dashboard,
      private_dashboard_exp: private_dashboard_exp
    } do
      access_token = private_dashboard_exp.token

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{access_token}")

      conn =
        post(
          conn,
          Routes.dashboard_export_path(conn, :show, dashboard.uuid, panel.id)
        )

      result = conn |> json_response(200)

      refute is_nil(result)

      assert Map.has_key?(result, "id")
      assert Map.has_key?(result, "name")
    end
  end
end
