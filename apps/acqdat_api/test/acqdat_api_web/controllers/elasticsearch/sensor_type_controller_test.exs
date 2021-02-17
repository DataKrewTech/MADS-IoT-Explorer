defmodule AcqdatApiWeb.ElasticSearch.SensorTypeControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Factory.ElasticSearch.SensorType
  import AcqdatCore.Support.Factory

  describe "search_sensor_type/2" do
    setup :setup_conn

    setup do
      sensor_type = insert(:sensor_type)
      SensorType.seed_sensor_type(sensor_type)
      :timer.sleep(2500)

      on_exit(fn ->
        SensorType.delete_index()
      end)

      [sensor_type: sensor_type]
    end

    test "fails if authorization header not found", %{conn: conn, sensor_type: sensor_type} do
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

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "search with valid params", %{conn: conn, sensor_type: sensor_type} do
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

      assert rsensor_type["id"] == sensor_type.id
      assert rsensor_type["project_id"] == sensor_type.project_id
      assert rsensor_type["slug"] == sensor_type.slug
      assert rsensor_type["uuid"] == sensor_type.uuid
      assert rsensor_type["name"] == sensor_type.name
    end

    test "search with no hits", %{conn: conn, sensor_type: sensor_type} do
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

      assert result == %{
               "sensor_types" => [],
               "total_entries" => 0
             }
    end
  end

  describe "index sensor types/2" do
    setup :setup_conn

    setup do
      project = insert(:project)

      [sensor_type1, sensor_type2, sensor_type3] =
        SensorType.seed_multiple_sensor_type(project, 3)

      :timer.sleep(2500)

      on_exit(fn ->
        SensorType.delete_index()
      end)

      [
        sensor_type1: sensor_type1,
        sensor_type2: sensor_type2,
        sensor_type3: sensor_type3,
        project: project
      ]
    end

    test "fails if authorization header not found", %{conn: conn, project: project} do
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

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "index with valid params and multiple entries", %{
      conn: conn,
      sensor_type1: sensor_type1,
      sensor_type2: sensor_type2,
      sensor_type3: sensor_type3,
      project: project
    } do
      conn =
        get(conn, Routes.sensor_type_path(conn, :index, project.org_id, project.id), %{
          "from" => 0,
          "page_size" => 3
        })

      %{"sensor_types" => sensor_types} = conn |> json_response(200)

      assert length(sensor_types) == 3
      [rsensor_type1, rsensor_type2, rsensor_type3] = sensor_types
      assert rsensor_type1["id"] == sensor_type1.id
      assert rsensor_type2["id"] == sensor_type2.id
      assert rsensor_type3["id"] == sensor_type3.id
    end
  end

  describe "update and delete sensor type/2" do
    setup :setup_conn

    setup do
      sensor_type = insert(:sensor_type)
      SensorType.seed_sensor_type(sensor_type)
      :timer.sleep(2500)

      on_exit(fn ->
        SensorType.delete_index()
      end)

      [sensor_type: sensor_type]
    end

    test "if sensor type is updated", %{conn: conn, sensor_type: sensor_type} do
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

      :timer.sleep(2500)

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

      assert rsensor_type["id"] == sensor_type.id
      assert rsensor_type["project_id"] == sensor_type.project_id
      assert rsensor_type["slug"] == sensor_type.slug
      assert rsensor_type["uuid"] == sensor_type.uuid
      assert rsensor_type["name"] == "Random Name ?"
    end

    test "if sensor type is deleted", %{conn: conn, sensor_type: sensor_type} do
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

      :timer.sleep(2500)

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

      assert result == %{
               "sensor_types" => [],
               "total_entries" => 0
             }
    end
  end
end
