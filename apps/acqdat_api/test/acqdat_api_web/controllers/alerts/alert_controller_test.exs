defmodule AcqdatApiWeb.Alerts.AlertControllerTest do
  @moduledoc """
  Test cases for the API of alert endpoints
  """
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "update/2" do
    setup :setup_conn

    test "update alert", %{conn: conn, org: org} do
      params = %{
        communication_medium: ["sms, e-mail"]
      }

      alert = insert(:alert)

      conn =
        put(
          conn,
          Routes.alert_path(conn, :update, org.id, alert.id),
          params
        )

      response = conn |> json_response(200)

      assert Map.has_key?(response, "entity_name")
      assert Map.has_key?(response, "status")
      assert Map.has_key?(response, "severity")
      assert Map.has_key?(response, "policy_name")
      assert Map.has_key?(response, "rule_parameters")
      assert Map.has_key?(response, "org_id")
      assert response["entity_id"] == alert.entity_id
    end

    test "fails if authorization header not found", %{conn: conn, org: org} do
      bad_access_token = "qwerty1234567uiop"
      alert = insert(:alert)
      # added bad access token here
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}

      conn =
        put(
          conn,
          Routes.alert_path(conn, :update, org.id, alert.id),
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

    test "alert delete", %{conn: conn, org: org} do
      alert = insert(:alert)

      conn =
        delete(
          conn,
          Routes.alert_path(conn, :delete, org.id, alert.id)
        )

      response = conn |> json_response(200)
      assert Map.has_key?(response, "entity_name")
      assert Map.has_key?(response, "status")
      assert Map.has_key?(response, "severity")
      assert Map.has_key?(response, "policy_name")
      assert Map.has_key?(response, "rule_parameters")
      assert Map.has_key?(response, "org_id")
      assert response["entity_id"] == alert.entity_id
    end

    test "fails if invalid token in authorization header", %{conn: conn, org: org} do
      bad_access_token = "qwerty1234567uiop"

      alert = insert(:alert)
      # added bad access token here
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        delete(
          conn,
          Routes.alert_path(conn, :delete, org.id, alert.id)
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

  describe "index/2" do
    setup :setup_conn

    test "list alert", %{conn: conn, org: org} do
      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      insert_list(3, :alert)
      conn = get(conn, Routes.alert_path(conn, :index, org.id, params))

      response = conn |> json_response(200)
      assert response["alerts"]
    end

    test "fails if invalid token in authorization header", %{conn: conn, org: org} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      insert_list(3, :alert)

      conn = get(conn, Routes.alert_path(conn, :index, org.id, params))

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
