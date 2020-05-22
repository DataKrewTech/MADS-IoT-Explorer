defmodule AcqdatApiWeb.EntityManagement.SensorTypeControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_conn

    test "sensor type create", %{conn: conn, org: org} do
      sensor_type_manifest = build(:sensor_type)
      project = insert(:project)

      data = %{
        name: sensor_type_manifest.name,
        parameters: sensor_type_manifest.parameters,
        metadata: sensor_type_manifest.metadata
      }

      conn = post(conn, Routes.sensor_type_path(conn, :create, org.id, project.id), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "org_id")
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "uuid")
      assert Map.has_key?(response, "parameters")
      assert Map.has_key?(response, "metadata")
      assert Map.has_key?(response, "slug")
    end

    test "fails if authorization header not found", %{conn: conn, org: org} do
      bad_access_token = "qwerty1234567uiop"
      project = insert(:project)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.sensor_type_path(conn, :create, org.id, project.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if sent params are not unique", %{conn: conn, org: org} do
      sensor_type_manifest = build(:sensor_type)
      project = insert(:project)

      data = %{
        name: sensor_type_manifest.name,
        parameters: sensor_type_manifest.parameters,
        metadata: sensor_type_manifest.metadata
      }

      conn = post(conn, Routes.sensor_type_path(conn, :create, org.id, project.id), data)
      conn = post(conn, Routes.sensor_type_path(conn, :create, org.id, project.id), data)
      response = conn |> json_response(400)

      assert response == %{
               "errors" => %{
                 "message" => %{"error" => %{"name" => ["sensor type already exists"]}}
               }
             }
    end

    test "fails if required params are missing", %{conn: conn, org: org} do
      sensor_type = insert(:sensor_type)
      project = insert(:project)

      conn = post(conn, Routes.sensor_type_path(conn, :create, org.id, project.id), %{})

      response = conn |> json_response(400)

      assert response == %{
               "errors" => %{
                 "message" => %{
                   "name" => ["can't be blank"],
                   "parameters" => ["can't be blank"]
                 }
               }
             }
    end
  end

  describe "update/2" do
    setup :setup_conn

    test "sensor type update", %{conn: conn, org: org} do
      sensor_type = insert(:sensor_type)
      project = insert(:project)
      data = Map.put(%{}, :name, "Water Plant")

      conn =
        put(
          conn,
          Routes.sensor_type_path(conn, :update, org.id, project.id, sensor_type.id),
          data
        )

      response = conn |> json_response(200)

      assert Map.has_key?(response, "org_id")
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "uuid")
      assert Map.has_key?(response, "parameters")
      assert Map.has_key?(response, "metadata")
      assert Map.has_key?(response, "slug")
    end

    test "fails if invalid token in authorization header", %{conn: conn, org: org} do
      bad_access_token = "qwerty12345678qwer"
      project = insert(:project)
      sensor_type = insert(:sensor_type)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = Map.put(%{}, :name, "Water Plant")

      conn =
        put(
          conn,
          Routes.sensor_type_path(conn, :update, org.id, project.id, sensor_type.id),
          data
        )

      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "delete/2" do
    setup :setup_conn

    test "sensor type delete", %{conn: conn, org: org} do
      sensor_type = insert(:sensor_type)
      project = insert(:project)

      conn =
        delete(
          conn,
          Routes.sensor_type_path(conn, :delete, org.id, project.id, sensor_type.id),
          %{}
        )

      response = conn |> json_response(200)

      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "uuid")
    end

    test "fails if invalid token in authorization header", %{conn: conn, org: org} do
      sensor_type = insert(:sensor_type)
      project = insert(:project)
      bad_access_token = "qwerty1234567qwerty"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        delete(
          conn,
          Routes.sensor_type_path(conn, :delete, org.id, project.id, sensor_type.id),
          %{}
        )

      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "index/2" do
    setup :setup_conn

    test "Sensor Data", %{conn: conn, org: org} do
      test_sensor = insert(:sensor_type)
      project = insert(:project)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn = get(conn, Routes.sensor_type_path(conn, :index, org.id, project.id, params))
      response = conn |> json_response(200)

      assert length(response["sensors_type"]) == 1
      assertion_sensor = List.first(response["sensors_type"])
      assert assertion_sensor["id"] == test_sensor.id
      assert assertion_sensor["org"]["id"] == test_sensor.org.id
      assert assertion_sensor["org"]["name"] == test_sensor.org.name
    end

    test "if params are missing", %{conn: conn, org: org} do
      insert_list(3, :sensor_type)
      project = insert(:project)
      conn = get(conn, Routes.sensor_type_path(conn, :index, org.id, project.id, %{}))
      response = conn |> json_response(200)
      assert response["total_pages"] == 1
      assert length(response["sensors_type"]) == response["total_entries"]
    end

    test "Big page size", %{conn: conn, org: org} do
      insert_list(3, :sensor_type)
      project = insert(:project)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn = get(conn, Routes.sensor_type_path(conn, :index, org.id, project.id, params))
      response = conn |> json_response(200)
      assert response["page_number"] == params["page_number"]
      assert response["page_size"] == params["page_size"]
      assert response["total_pages"] == 1
      assert length(response["sensors_type"]) == response["total_entries"]
    end

    test "Pagination", %{conn: conn, org: org} do
      insert_list(3, :sensor_type)
      project = insert(:project)

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn = get(conn, Routes.sensor_type_path(conn, :index, org.id, project.id, params))
      page1_response = conn |> json_response(200)
      assert page1_response["page_number"] == params["page_number"]
      assert page1_response["page_size"] == params["page_size"]
      assert page1_response["total_pages"] == 2
      assert length(page1_response["sensors_type"]) == page1_response["page_size"]

      params = Map.put(params, "page_number", 2)
      conn = get(conn, Routes.sensor_type_path(conn, :index, org.id, project.id, params))
      page2_response = conn |> json_response(200)

      assert page2_response["page_number"] == params["page_number"]
      assert page2_response["page_size"] == params["page_size"]
      assert page2_response["total_pages"] == 2
      assert length(page2_response["sensors_type"]) == 1
    end

    test "fails if invalid token in authorization header", %{conn: conn, org: org} do
      bad_access_token = "qwerty1234567qwerty12"
      project = insert(:project)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn = get(conn, Routes.sensor_type_path(conn, :index, org.id, project.id, params))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end
end
