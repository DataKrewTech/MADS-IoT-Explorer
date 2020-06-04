defmodule AcqdatApiWeb.EntityManagement.SensorControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_conn

    test "sensor create", %{conn: conn} do
      asset = insert(:asset)

      # sensor_type = insert(:sensor_type)

      sensor_manifest = build(:sensor)

      data = %{
        name: sensor_manifest.name,
        uuid: sensor_manifest.uuid,
        parent_id: asset.id,
        parent_type: "Asset"
      }

      conn = post(conn, Routes.sensor_path(conn, :create, asset.org_id, asset.project_id), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "parent_id")
      assert Map.has_key?(response, "parent_type")
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      # assert Map.has_key?(response, "sensor_type_id")
      assert Map.has_key?(response, "uuid")
    end

    test "fails if authorization header not found", %{conn: conn} do
      bad_access_token = "qwerty1234567uiop"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.sensor_path(conn, :create, 1, 1), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "update/2" do
    setup :setup_conn

    setup do
      project = insert(:project)
      asset = insert(:asset)
      sensor = insert(:sensor)
      [project: project, asset: asset, sensor: sensor]
    end

    test "update sensor name", %{conn: conn, sensor: sensor, asset: asset} do
      data = Map.put(%{}, :name, "Water Plant")

      conn =
        put(
          conn,
          Routes.sensor_path(conn, :update, asset.org_id, asset.project_id, sensor.id),
          data
        )

      response = conn |> json_response(200)

      assert Map.has_key?(response, "parent_id")
      assert Map.has_key?(response, "parent_type")
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      # assert Map.has_key?(response, "sensor_type_id")
      assert Map.has_key?(response, "uuid")
      assert response["name"] == "Water Plant"
    end

    test "update sensor parent to project", %{conn: conn, sensor: sensor, project: project} do
      data = %{
        parent_id: project.id,
        parent_type: "Project"
      }

      conn =
        put(conn, Routes.sensor_path(conn, :update, project.org_id, project.id, sensor.id), data)

      response = conn |> json_response(200)

      assert Map.has_key?(response, "parent_id")
      assert Map.has_key?(response, "parent_type")
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      # assert Map.has_key?(response, "sensor_type_id")
      assert Map.has_key?(response, "uuid")
      assert response["parent_id"] == project.id
      assert response["parent_type"] == "Project"
    end

    test "fails if invalid token in authorization header", %{
      conn: conn,
      sensor: sensor,
      asset: asset
    } do
      bad_access_token = "qwerty12345678qwer"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = Map.put(%{}, :name, "Water Plant")

      conn =
        put(
          conn,
          Routes.sensor_path(conn, :update, asset.org_id, asset.project_id, sensor.id),
          data
        )

      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "delete/2" do
    setup :setup_conn

    setup do
      asset = insert(:asset)
      sensor = insert(:sensor)
      [asset: asset, sensor: sensor]
    end

    test "sensor delete", %{conn: conn, sensor: sensor, asset: asset} do
      conn =
        delete(conn, Routes.sensor_path(conn, :delete, asset.org_id, asset.project_id, sensor.id))

      response = conn |> json_response(200)
      assert Map.has_key?(response, "parent_id")
      assert Map.has_key?(response, "parent_type")
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      # assert Map.has_key?(response, "sensor_type_id")
      assert Map.has_key?(response, "uuid")
    end

    test "fails if invalid token in authorization header", %{
      conn: conn,
      sensor: sensor,
      asset: asset
    } do
      bad_access_token = "qwerty1234567qwerty"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        delete(conn, Routes.sensor_path(conn, :delete, asset.org_id, asset.project_id, sensor.id))

      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "index/2" do
    setup :setup_conn

    setup do
      sensor = insert(:asset)
      [sensor: sensor]
    end

    test "list sensors data of a project", %{conn: conn, sensor: sensor} do
      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn = get(conn, Routes.sensor_path(conn, :index, sensor.org_id, sensor.project_id, params))
      response = conn |> json_response(200)
      assert response["sensors"]
    end

    test "fails if invalid token in authorization header", %{conn: conn, sensor: sensor} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn = get(conn, Routes.sensor_path(conn, :index, sensor.org_id, sensor.project_id, params))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end
end
