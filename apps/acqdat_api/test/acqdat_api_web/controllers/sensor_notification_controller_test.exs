defmodule AcqdatApiWeb.SensorNotificationControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Model.User
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_conn

    test "sensor notification create", %{conn: conn} do
      sensor_notification_manifest = build(:sensor_notification)
      sensor_manifest = insert(:sensor)

      data = %{
        rule_values: sensor_notification_manifest.rule_values,
        alarm_status: sensor_notification_manifest.alarm_status,
        sensor_id: sensor_manifest.id
      }

      conn = post(conn, Routes.sensor_notification_path(conn, :create), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "rule_values")
      assert Map.has_key?(response, "alarm_status")
      assert Map.has_key?(response, "sensor_id")
    end

    test "fails if authorization header not found", %{conn: conn} do
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.sensor_notification_path(conn, :create), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if sent params are not unique", %{conn: conn} do
      sensor_notification_manifest = insert(:sensor_notification)
      sensor_manifest = insert(:sensor)

      data = %{
        rule_values: sensor_notification_manifest.rule_values,
        alarm_status: sensor_notification_manifest.alarm_status,
        sensor_id: sensor_manifest.id
      }

      conn = post(conn, Routes.sensor_notification_path(conn, :create), data)
      conn = post(conn, Routes.sensor_notification_path(conn, :create), data)
      response = conn |> json_response(400)

      assert response == %{
               "errors" => %{
                 "message" => %{"error" => %{"sensor_id" => ["has already been taken"]}}
               }
             }
    end

    test "fails if required params are missing", %{conn: conn} do
      sensor_manifest = insert(:sensor)

      conn =
        post(conn, Routes.sensor_notification_path(conn, :create), %{
          sensor_id: sensor_manifest.id
        })

      response = conn |> json_response(400)
      assert response == %{"errors" => %{"message" => %{"rule_values" => ["can't be blank"]}}}
    end
  end

  describe "update/2" do
    setup :setup_conn

    test "sensor notification update", %{conn: conn} do
      sensor_notification = insert(:sensor_notification)

      data = %{
        rule_values: %{
          "sense" => %{
            "module" => "Elixir.AcqdatCore.Schema.Notification.RangeBased",
            "preferences" => %{"lower_limit" => "110.0", "upper_limit" => "120"}
          }
        },
        alarm_status: false
      }

      conn =
        put(conn, Routes.sensor_notification_path(conn, :update, sensor_notification.id), data)

      response = conn |> json_response(200)
      assert Map.has_key?(response, "rule_values")
      assert Map.has_key?(response, "alarm_status")
      assert Map.has_key?(response, "sensor_id")
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "avcbd123489u"
      sensor_notification_manifest = insert(:sensor_notification)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{
        alarm_status: false
      }

      conn =
        put(
          conn,
          Routes.sensor_notification_path(conn, :update, sensor_notification_manifest.id),
          data
        )

      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "delete/2" do
    setup :setup_conn

    test "sensor type delete", %{conn: conn} do
      sensor_notification = insert(:sensor_notification)

      conn =
        delete(conn, Routes.sensor_notification_path(conn, :delete, sensor_notification.id), %{})

      response = conn |> json_response(200)
      assert Map.has_key?(response, "rule_values")
      assert Map.has_key?(response, "alarm_status")
      assert Map.has_key?(response, "sensor_id")
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      sensor_notification = insert(:sensor_notification)
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        delete(conn, Routes.sensor_notification_path(conn, :delete, sensor_notification.id), %{})

      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "index/2" do
    setup :setup_conn

    test "Big page size", %{conn: conn} do
      insert_list(3, :sensor_notification)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn = get(conn, Routes.sensor_notification_path(conn, :index, params))
      response = conn |> json_response(200)
      assert response["page_number"] == params["page_number"]
      assert response["page_size"] == params["page_size"]
      assert response["total_pages"] == 1
      assert length(response["sensor_notification"]) == response["total_entries"]
    end

    test "Pagination", %{conn: conn} do
      insert_list(3, :sensor_notification)

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn = get(conn, Routes.sensor_notification_path(conn, :index, params))
      page1_response = conn |> json_response(200)
      assert page1_response["page_number"] == params["page_number"]
      assert page1_response["page_size"] == params["page_size"]
      assert page1_response["total_pages"] == 2
      assert length(page1_response["sensor_notification"]) == page1_response["page_size"]

      params = Map.put(params, "page_number", 2)
      conn = get(conn, Routes.sensor_notification_path(conn, :index, params))
      page2_response = conn |> json_response(200)

      assert page2_response["page_number"] == params["page_number"]
      assert page2_response["page_size"] == params["page_size"]
      assert page2_response["total_pages"] == 2
      assert length(page2_response["sensor_notification"]) == 1
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "avcbd12 3489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn = get(conn, Routes.sensor_notification_path(conn, :index, params))
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
