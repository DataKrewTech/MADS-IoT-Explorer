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

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
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
               "detail" =>
                 "Parameters provided to perform current action is either not valid or missing or not unique",
               "source" => %{"name" => ["sensor type already exists"]},
               "status_code" => 400,
               "title" => "Insufficient or not unique parameters"
             }
    end

    test "fails if required params are missing", %{conn: conn, org: org} do
      project = insert(:project)

      conn = post(conn, Routes.sensor_type_path(conn, :create, org.id, project.id), %{})
      response = conn |> json_response(400)

      assert response == %{
               "detail" =>
                 "Parameters provided to perform current action is either not valid or missing or not unique",
               "source" => %{"name" => ["can't be blank"]},
               "status_code" => 400,
               "title" => "Insufficient or not unique parameters"
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

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
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

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end
  end
end
