defmodule AcqdatApiWeb.EntityManagement.EntityControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "fetch_hierarchy/2" do
    setup :setup_conn

    setup do
      asset = insert(:asset)
      [asset: asset]
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = get(conn, Routes.entity_path(conn, :fetch_hierarchy, 1, 1))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "shows hirerachy tree of the respective project", %{conn: conn, asset: asset} do
      conn = get(conn, Routes.entity_path(conn, :fetch_hierarchy, asset.org_id, asset.project_id))
      result = conn |> json_response(200)

      assert result["id"] == asset.org_id
      assert result["type"] == "Organisation"
    end
  end

  describe "fetch_count/2" do
    setup :setup_conn

    setup do
      project = insert(:project)
      asset = insert(:asset)
      sensor = insert(:sensor)
      asset_type = insert(:asset_type)
      sensor_type = insert(:sensor_type)

      [
        project: project,
        asset: asset,
        sensor: sensor,
        asset_type: asset_type,
        sensor_type: sensor_type
      ]
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = post(conn, Routes.entity_path(conn, :fetch_count), %{})
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "shows asset count per project", %{conn: conn, asset: asset} do
      params = %{type: "Asset", project_id: asset.project_id}
      conn = post(conn, Routes.entity_path(conn, :fetch_count), params)
      result = conn |> json_response(200)

      assert result["count"] == 1

      conn = post(conn, Routes.entity_path(conn, :fetch_count), %{type: "Asset", project_id: -1})
      result = conn |> json_response(200)

      assert result["count"] == 0
    end

    test "shows asset_type count per project", %{conn: conn, asset_type: asset_type} do
      params = %{type: "AssetType", project_id: asset_type.project_id}
      conn = post(conn, Routes.entity_path(conn, :fetch_count), params)
      result = conn |> json_response(200)

      assert result["count"] == 1

      conn =
        post(conn, Routes.entity_path(conn, :fetch_count), %{type: "AssetType", project_id: -1})

      result = conn |> json_response(200)

      assert result["count"] == 0
    end

    test "shows sensor count per project", %{conn: conn, sensor: sensor} do
      params = %{type: "Sensor", project_id: sensor.project_id}
      conn = post(conn, Routes.entity_path(conn, :fetch_count), params)
      result = conn |> json_response(200)

      assert result["count"] == 1

      conn = post(conn, Routes.entity_path(conn, :fetch_count), %{type: "Sensor", project_id: -1})
      result = conn |> json_response(200)

      assert result["count"] == 0
    end

    test "shows sensor_type count per project", %{conn: conn, sensor_type: sensor_type} do
      params = %{type: "SensorType", project_id: sensor_type.project_id}
      conn = post(conn, Routes.entity_path(conn, :fetch_count), params)
      result = conn |> json_response(200)

      assert result["count"] == 1

      conn =
        post(conn, Routes.entity_path(conn, :fetch_count), %{type: "SensorType", project_id: -1})

      result = conn |> json_response(200)

      assert result["count"] == 0
    end

    test "shows project count", %{conn: conn} do
      params = %{type: "Project"}
      conn = post(conn, Routes.entity_path(conn, :fetch_count), params)
      result = conn |> json_response(200)

      assert result["count"] >= 1
    end
  end
end
