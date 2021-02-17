defmodule AcqdatApiWeb.ElasticSearch.SensorControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Factory.ElasticSearch.Sensor
  import AcqdatCore.Support.Factory

  describe "search_sensors/2" do
    setup :setup_conn

    setup do
      sensor = insert(:sensor)
      Sensor.seed_sensor(sensor)
      :timer.sleep(2500)

      on_exit(fn ->
        Sensor.delete_index()
      end)

      [sensor: sensor]
    end

    test "fails if authorization header not found", %{conn: conn, sensor: sensor} do
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(
          conn,
          Routes.search_sensors_path(conn, :search_sensors, sensor.org_id, sensor.project_id),
          %{
            "label" => sensor.name
          }
        )

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "search with valid params", %{conn: conn, sensor: sensor} do
      conn =
        get(
          conn,
          Routes.search_sensors_path(conn, :search_sensors, sensor.org_id, sensor.project_id),
          %{
            "label" => sensor.name
          }
        )

      result = conn |> json_response(200)

      sensor_type = sensor.sensor_type

      assert result == %{
               "sensors" => [
                 %{
                   "gateway_id" => sensor.gateway_id,
                   "id" => sensor.id,
                   "metadata" => sensor.metadata,
                   "name" => sensor.name,
                   "org_id" => sensor.org_id,
                   "parent_id" => sensor.parent_id,
                   "parent_type" => sensor.parent_type,
                   "project_id" => sensor.project_id,
                   "sensor_type_id" => sensor.sensor_type_id,
                   "slug" => sensor.slug,
                   "uuid" => sensor.uuid,
                   "description" => sensor.description,
                   "sensor_type" => %{
                     "description" => sensor_type.description,
                     "generated_by" => "user",
                     "id" => sensor_type.id,
                     "metadata" => convert_list_of_struct_to_list_of_map(sensor_type.metadata),
                     "name" => sensor_type.name,
                     "org_id" => sensor_type.org_id,
                     "parameters" =>
                       convert_list_of_struct_to_list_of_map(sensor_type.parameters),
                     "project_id" => sensor_type.project_id,
                     "slug" => sensor_type.slug,
                     "uuid" => sensor_type.uuid
                   }
                 }
               ],
               "total_entries" => 1
             }
    end

    test "search with no hits", %{conn: conn, sensor: sensor} do
      project = insert(:project)

      conn =
        get(
          conn,
          Routes.search_sensors_path(conn, :search_sensors, project.org_id, project.id),
          %{
            "label" => sensor.name
          }
        )

      result = conn |> json_response(200)

      assert result == %{
               "sensors" => [],
               "total_entries" => 0
             }
    end
  end

  describe "index sensors/2" do
    setup :setup_conn

    setup do
      project = insert(:project)
      [sensor1, sensor2, sensor3] = Sensor.seed_multiple_sensors(project, 3)
      :timer.sleep(2500)

      on_exit(fn ->
        Sensor.delete_index()
      end)

      [sensor1: sensor1, sensor2: sensor2, sensor3: sensor3]
    end

    test "fails if authorization header not found", %{conn: conn} do
      project = insert(:project)
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(conn, Routes.sensor_path(conn, :index, project.org_id, project.id), %{
          "from" => 0,
          "page_size" => 1
        })

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "index with valid params and multiple entries", %{
      conn: conn,
      sensor1: sensor1,
      sensor2: sensor2,
      sensor3: sensor3
    } do
      conn =
        get(conn, Routes.sensor_path(conn, :index, sensor3.project.org_id, sensor3.project.id), %{
          "from" => 0,
          "page_size" => 3
        })

      %{"sensors" => sensors} = conn |> json_response(200)

      assert length(sensors) == 3
      [rsensor1, rsensor2, rsensor3] = sensors
      assert rsensor1["id"] == sensor1.id
      assert rsensor2["id"] == sensor2.id
      assert rsensor3["id"] == sensor3.id
    end
  end

  describe "update and delete sensors/2" do
    setup :setup_conn

    setup do
      sensor = insert(:sensor)
      Sensor.seed_sensor(sensor)
      :timer.sleep(2500)

      on_exit(fn ->
        Sensor.delete_index()
      end)

      [sensor: sensor]
    end

    test "if sensor is updated", %{conn: conn, sensor: sensor} do
      conn =
        put(
          conn,
          Routes.sensor_path(conn, :update, sensor.org_id, sensor.project_id, sensor.id),
          %{
            "name" => "Testing Sensor"
          }
        )

      :timer.sleep(2500)

      conn =
        get(
          conn,
          Routes.search_sensors_path(conn, :search_sensors, sensor.org_id, sensor.project_id),
          %{
            "label" => "Testing Sensor"
          }
        )

      result = conn |> json_response(200)

      sensor_type = sensor.sensor_type

      assert result == %{
               "sensors" => [
                 %{
                   "gateway_id" => sensor.gateway_id,
                   "id" => sensor.id,
                   "metadata" => sensor.metadata,
                   "name" => "Testing Sensor",
                   "org_id" => sensor.org_id,
                   "parent_id" => sensor.parent_id,
                   "parent_type" => sensor.parent_type,
                   "project_id" => sensor.project_id,
                   "sensor_type_id" => sensor.sensor_type_id,
                   "description" => sensor.description,
                   "sensor_type" => %{
                     "description" => sensor_type.description,
                     "generated_by" => "user",
                     "id" => sensor_type.id,
                     "metadata" => convert_list_of_struct_to_list_of_map(sensor_type.metadata),
                     "name" => sensor_type.name,
                     "org_id" => sensor_type.org_id,
                     "parameters" =>
                       convert_list_of_struct_to_list_of_map(sensor_type.parameters),
                     "project_id" => sensor_type.project_id,
                     "slug" => sensor_type.slug,
                     "uuid" => sensor_type.uuid
                   },
                   "slug" => sensor.slug,
                   "uuid" => sensor.uuid
                 }
               ],
               "total_entries" => 1
             }
    end

    test "if sensor is deleted", %{conn: conn, sensor: sensor} do
      conn =
        delete(
          conn,
          Routes.sensor_path(conn, :delete, sensor.org_id, sensor.project_id, sensor.id)
        )

      :timer.sleep(2500)

      conn =
        get(
          conn,
          Routes.search_sensors_path(conn, :search_sensors, sensor.org_id, sensor.project_id),
          %{
            "label" => sensor.name
          }
        )

      result = conn |> json_response(200)

      assert result == %{
               "sensors" => [],
               "total_entries" => 0
             }
    end
  end

  defp convert_list_of_struct_to_list_of_map(params) do
    Enum.reduce(params, [], fn x, acc ->
      acc ++ [convert_atom_key_to_string(Map.from_struct(x))]
    end)
  end

  defp convert_atom_key_to_string(params) do
    for {key, val} <- params, into: %{}, do: {Atom.to_string(key), val}
  end
end
