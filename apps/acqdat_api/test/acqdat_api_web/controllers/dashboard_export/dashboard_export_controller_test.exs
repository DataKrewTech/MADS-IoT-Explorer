defmodule AcqdatApiWeb.DashboardExport.DashboardExportControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.DashboardExport.Schema.DashboardExport
  alias AcqdatCore.Repo
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_conn

    setup do
      dashboard = insert(:dashboard)

      [dashboard: dashboard]
    end

    test "create exported url publicly", %{conn: conn, org: org, dashboard: dashboard} do
      data = %{}
      conn = post(conn, Routes.dashboard_export_path(conn, :create, org.id, dashboard.id), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "url")
    end

    test "create exported url privately", %{conn: conn, org: org, dashboard: dashboard} do
      data = %{is_secure: true}
      conn = post(conn, Routes.dashboard_export_path(conn, :create, org.id, dashboard.id), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "url")
      require IEx
      IEx.pry()
    end
  end
end
