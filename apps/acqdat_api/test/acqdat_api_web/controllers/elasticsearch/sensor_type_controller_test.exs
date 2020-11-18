defmodule AcqdatApiWeb.ElasticSearch.SensorTypeControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Factory.ElasticSearch.SensorType
  import AcqdatCore.Support.Factory

  describe "search_sensor_type/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn} do
      sensor_type = insert(:sensor_type)
      SensorType.seed_sensor_type(sensor_type)
      :timer.sleep(1500)
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(
          conn,
          Routes.search_sensor_type_path(
            conn,
            :search_sensor_type,
            sensor_type.org_id,
            sensor_type.project_id
          ),
          %{
            "label" => sensor_type.name
          }
        )

      result = conn |> json_response(403)
      SensorType.delete_index()
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "search with valid params", %{conn: conn} do
      sensor_type = insert(:sensor_type)
      SensorType.seed_sensor_type(sensor_type)
      :timer.sleep(1500)

      conn =
        get(
          conn,
          Routes.search_sensor_type_path(
            conn,
            :search_sensor_type,
            sensor_type.org_id,
            sensor_type.project_id
          ),
          %{
            "label" => sensor_type.name
          }
        )

      %{
        "sensor_types" => [
          rsensor_type
        ]
      } = conn |> json_response(200)

      SensorType.delete_index()
      assert rsensor_type["id"] == sensor_type.id
      assert rsensor_type["project_id"] == sensor_type.project_id
      assert rsensor_type["slug"] == sensor_type.slug
      assert rsensor_type["uuid"] == sensor_type.uuid
      assert rsensor_type["name"] == sensor_type.name
    end

    test "search with no hits", %{conn: conn} do
      sensor_type = insert(:sensor_type)
      SensorType.seed_sensor_type(sensor_type)
      :timer.sleep(1500)

      conn =
        get(
          conn,
          Routes.search_sensor_type_path(
            conn,
            :search_sensor_type,
            sensor_type.org_id,
            sensor_type.project_id
          ),
          %{
            "label" => "Random Name ?"
          }
        )

      result = conn |> json_response(200)

      SensorType.delete_index()

      assert result == %{
               "sensor_types" => []
             }
    end
  end

  describe "index sensor types/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn} do
      project = insert(:project)
      SensorType.seed_multiple_sensor_type(project)
      :timer.sleep(1500)
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(conn, Routes.sensor_type_path(conn, :index, project.org_id, project.id), %{
          "from" => 0,
          "page_size" => 1
        })

      result = conn |> json_response(403)
      SensorType.delete_index()
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "index with valid params and multiple entries", %{conn: conn} do
      project = insert(:project)
      [sensor_type1, sensor_type2, sensor_type3] = SensorType.seed_multiple_sensor_type(project)
      :timer.sleep(1500)

      conn =
        get(conn, Routes.sensor_type_path(conn, :index, project.org_id, project.id), %{
          "from" => 0,
          "page_size" => 3
        })

      %{"sensor_types" => sensor_types} = conn |> json_response(200)

      SensorType.delete_index()
      assert length(sensor_types) == 3
      [rsensor_type1, rsensor_type2, rsensor_type3] = sensor_types
      assert rsensor_type1["id"] == sensor_type1.id
      assert rsensor_type2["id"] == sensor_type2.id
      assert rsensor_type3["id"] == sensor_type3.id
    end
  end

  describe "update and delete sensor type/2" do
    setup :setup_conn

    test "if sensor type is updated", %{conn: conn} do
      sensor_type = insert(:sensor_type)
      SensorType.seed_sensor_type(sensor_type)
      :timer.sleep(1500)

      conn =
        put(
          conn,
          Routes.sensor_type_path(
            conn,
            :update,
            sensor_type.org_id,
            sensor_type.project_id,
            sensor_type.id
          ),
          %{
            "name" => "Random Name ?"
          }
        )

      :timer.sleep(1500)

      conn =
        get(
          conn,
          Routes.search_sensor_type_path(
            conn,
            :search_sensor_type,
            sensor_type.org_id,
            sensor_type.project_id
          ),
          %{
            "label" => "Random Name ?"
          }
        )

      %{
        "sensor_types" => [
          rsensor_type
        ]
      } = conn |> json_response(200)

      SensorType.delete_index()
      assert rsensor_type["id"] == sensor_type.id
      assert rsensor_type["project_id"] == sensor_type.project_id
      assert rsensor_type["slug"] == sensor_type.slug
      assert rsensor_type["uuid"] == sensor_type.uuid
      assert rsensor_type["name"] == "Random Name ?"
    end

    test "if sensor type is deleted", %{conn: conn} do
      sensor_type = insert(:sensor_type)
      SensorType.seed_sensor_type(sensor_type)
      :timer.sleep(1500)

      conn =
        delete(
          conn,
          Routes.sensor_type_path(
            conn,
            :update,
            sensor_type.org_id,
            sensor_type.project_id,
            sensor_type.id
          )
        )

      :timer.sleep(1500)

      conn =
        get(
          conn,
          Routes.search_sensor_type_path(
            conn,
            :search_sensor_type,
            sensor_type.org_id,
            sensor_type.project_id
          ),
          %{
            "label" => sensor_type.name
          }
        )

      result = conn |> json_response(200)

      SensorType.delete_index()

      assert result == %{
               "sensor_types" => []
             }
    end
  end
end
