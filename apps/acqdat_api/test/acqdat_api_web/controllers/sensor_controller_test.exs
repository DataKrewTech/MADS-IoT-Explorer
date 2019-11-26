defmodule AcqdatApiWeb.SensorControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Model.User
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_conn

    test "sensor create", %{conn: conn} do
      device = insert(:device)
      sensor_type = insert(:sensor_type)

      sensor_manifest = build(:sensor)

      data = %{
        name: sensor_manifest.name,
        uuid: sensor_manifest.uuid
      }

      params = %{
        device_id: device.id,
        sensor_type_id: sensor_type.id
      }

      conn = post(conn, Routes.sensor_path(conn, :create, params), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "device_id")
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "sensor_type_id")
      assert Map.has_key?(response, "uuid")
    end

    test "fails if authorization header not found", %{conn: conn} do
      bad_access_token = "qwerty1234567uiop"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.sensor_path(conn, :create), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if sent params are not unique", %{conn: conn} do
      sensor = insert(:sensor)

      data = %{
        name: sensor.name,
        uuid: sensor.uuid
      }

      params = %{
        device_id: sensor.device_id,
        sensor_type_id: sensor.sensor_type_id
      }

      conn = post(conn, Routes.sensor_path(conn, :create, params), data)
      response = conn |> json_response(400)

      assert response == %{
               "errors" => %{
                 "message" => %{"error" => %{"name" => ["has already been taken"]}}
               }
             }
    end

    test "fails if required params are missing", %{conn: conn} do
      sensor = insert(:sensor)

      params = %{
        device_id: sensor.device_id,
        sensor_type_id: sensor.sensor_type_id
      }

      conn = post(conn, Routes.sensor_path(conn, :create, params), %{})

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

  describe "sensor_by_criteria/2" do
    setup :setup_conn

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        device_id: 3
      }

      conn = get(conn, Routes.sensor_path(conn, :sensor_by_criteria, params.device_id))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "sensors of a device with invalid device id", %{conn: conn} do
      sensor = insert(:sensor)
      params = %{
        device_id: 3
      }

      conn = get(conn, Routes.sensor_path(conn, :sensor_by_criteria, params.device_id))
      result = conn |> json_response(404)
      assert result == %{"errors" => %{"message" => "Resource Not Found"}}
    end

    test "sensors of a device with valid device id", %{conn: conn} do
      sensor = insert(:sensor)
      params = %{
        device_id: sensor.device_id
      }

      conn = get(conn, Routes.sensor_path(conn, :sensor_by_criteria, params.device_id))
      result = conn |> json_response(200)
      assert result == %{
        "sensors" => [
          %{
            "device_id" => sensor.device_id,
            "id" => sensor.id,
            "name" => sensor.name,
            "sensor_type" => %{
              "id" => sensor.sensor_type.id,
              "identifier" => sensor.sensor_type.identifier,
              "make" => sensor.sensor_type.make,
              "name" => sensor.sensor_type.name
            },
            "sensor_type_id" => sensor.sensor_type_id,
            "uuid" => sensor.uuid
          }
        ]
      }
    end
  end
  
  describe "update/2" do
    setup :setup_conn

    test "sensor update", %{conn: conn} do
      sensor = insert(:sensor)
      data = Map.put(%{}, :name, "Water Plant")

      conn = put(conn, Routes.sensor_path(conn, :update, sensor.id), data)
      response = conn |> json_response(200)

      assert Map.has_key?(response, "device_id")
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "sensor_type_id")
      assert Map.has_key?(response, "uuid")
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty12345678qwer"
      sensor = insert(:sensor)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = Map.put(%{}, :name, "Water Plant")
      conn = put(conn, Routes.device_path(conn, :update, sensor.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "delete/2" do
    setup :setup_conn

    test "device delete", %{conn: conn} do
      sensor = insert(:sensor)

      conn = delete(conn, Routes.sensor_path(conn, :delete, sensor.id), %{})
      response = conn |> json_response(200)
      assert Map.has_key?(response, "device_id")
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "sensor_type_id")
      assert Map.has_key?(response, "uuid")
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      sensor = insert(:sensor)
      bad_access_token = "qwerty1234567qwerty"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = delete(conn, Routes.sensor_path(conn, :delete, sensor.id), %{})
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "index/2" do
    setup :setup_conn

    test "Sensor Data", %{conn: conn} do
      test_sensor = insert(:sensor)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn = get(conn, Routes.sensor_path(conn, :index, params))
      response = conn |> json_response(200)
      assert length(response["sensors"]) == 1
      assertion_sensor = List.first(response["sensors"])
      assert assertion_sensor["id"] == test_sensor.id
      assert assertion_sensor["device_id"] == test_sensor.device_id
      assert assertion_sensor["device"]["id"] == test_sensor.device.id
      assert assertion_sensor["device"]["name"] == test_sensor.device.name
      assert assertion_sensor["sensor_type_id"] == test_sensor.sensor_type_id
      assert assertion_sensor["sensor_type"]["id"] == test_sensor.sensor_type.id
      assert assertion_sensor["sensor_type"]["name"] == test_sensor.sensor_type.name
    end

    test "Big page size", %{conn: conn} do
      insert_list(3, :sensor)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn = get(conn, Routes.sensor_path(conn, :index, params))
      response = conn |> json_response(200)
      assert response["page_number"] == params["page_number"]
      assert response["page_size"] == params["page_size"]
      assert response["total_pages"] == 1
      assert length(response["sensors"]) == response["total_entries"]
    end

    test "Pagination", %{conn: conn} do
      insert_list(3, :sensor)

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn = get(conn, Routes.sensor_path(conn, :index, params))
      page1_response = conn |> json_response(200)
      assert page1_response["page_number"] == params["page_number"]
      assert page1_response["page_size"] == params["page_size"]
      assert page1_response["total_pages"] == 2
      assert length(page1_response["sensors"]) == page1_response["page_size"]

      params = Map.put(params, "page_number", 2)
      conn = get(conn, Routes.sensor_path(conn, :index, params))
      page2_response = conn |> json_response(200)

      assert page2_response["page_number"] == params["page_number"]
      assert page2_response["page_size"] == params["page_size"]
      assert page2_response["total_pages"] == 2
      assert length(page2_response["sensors"]) == 1
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn = get(conn, Routes.sensor_path(conn, :index, params))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  def setup_conn(%{conn: conn}) do
    params =
      build(:user)
      |> Map.put(:password, "stark1234")
      |> Map.put(:password_confirmation, "stark1234")
      |> Map.from_struct()

    {:ok, user} = User.create(params)
    sign_in_data = %{email: user.email, password: params.password}
    conn = post(conn, Routes.auth_path(conn, :sign_in), sign_in_data)
    result = conn |> json_response(200)
    access_token = result["access_token"]

    conn =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer #{access_token}")

    [conn: conn]
  end
end
