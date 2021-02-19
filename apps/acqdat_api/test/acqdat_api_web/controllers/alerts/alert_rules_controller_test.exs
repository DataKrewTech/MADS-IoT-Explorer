defmodule AcqdatApiWeb.Alerts.AlertRulesControllerTest do
  @moduledoc """
  Test cases for the API of alertrules endpoints
  """
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Alerts.Model.AlertRules

  @doc """
  test for the creation of alert rule
  """
  describe "create/2" do
    setup :setup_conn
    setup :setup_alert_rules

    test "create alert rule", %{conn: conn, alert_rule: alert_rule, org: org} do
      conn =
        post(
          conn,
          Routes.alert_rules_path(conn, :create, org.id),
          alert_rule
        )

      response = conn |> json_response(200)

      assert Map.has_key?(response, "entity")
      assert Map.has_key?(response, "entity_parameters")
      assert Map.has_key?(response, "policy_name")
      assert Map.has_key?(response, "rule_parameters")
      assert Map.has_key?(response, "org_id")
      assert Map.has_key?(response, "slug")
      assert response["entity_id"] == alert_rule.entity_id
    end

    test "fails if authorization header not found", %{
      conn: conn,
      alert_rule: alert_rule,
      org: org
    } do
      bad_access_token = "qwerty1234567uiop"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        post(
          conn,
          Routes.alert_rules_path(conn, :create, org.id),
          alert_rule
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

  describe "update/2" do
    setup :setup_conn
    setup :setup_alert_rules

    test "update alert rule", %{conn: conn, alert_rule: alert_rule, org: org} do
      params = %{
        communication_medium: ["sms, e-mail"]
      }

      # first inserted the alert rule
      conn =
        post(
          conn,
          Routes.alert_rules_path(conn, :create, org.id),
          alert_rule
        )

      response = conn |> json_response(200)

      conn =
        put(
          conn,
          Routes.alert_rules_path(conn, :update, org.id, response["id"]),
          params
        )

      response = conn |> json_response(200)
      assert Map.has_key?(response, "entity")
      assert Map.has_key?(response, "entity_parameters")
      assert Map.has_key?(response, "policy_name")
      assert Map.has_key?(response, "rule_parameters")
      assert Map.has_key?(response, "org_id")
      assert Map.has_key?(response, "slug")
      assert response["entity_id"] == alert_rule.entity_id
    end

    test "fails if authorization header not found", %{
      conn: conn,
      alert_rule: alert_rule,
      org: org
    } do
      bad_access_token = "qwerty1234567uiop"
      {:ok, alert_rule} = AlertRules.create(alert_rule)

      # added bad access token here
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}

      conn =
        put(
          conn,
          Routes.alert_rules_path(conn, :update, org.id, alert_rule.id),
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
    setup :setup_alert_rules

    test "alert rule delete", %{conn: conn, alert_rule: alert_rule, org: org} do
      {:ok, alert_rule} = AlertRules.create(alert_rule)

      conn =
        delete(
          conn,
          Routes.alert_rules_path(conn, :delete, org.id, alert_rule.id)
        )

      response = conn |> json_response(200)
      assert Map.has_key?(response, "entity")
      assert Map.has_key?(response, "entity_parameters")
      assert Map.has_key?(response, "policy_name")
      assert Map.has_key?(response, "rule_parameters")
      assert Map.has_key?(response, "org_id")
      assert Map.has_key?(response, "slug")
      assert response["entity_id"] == alert_rule.entity_id
    end

    test "fails if invalid token in authorization header", %{
      conn: conn,
      alert_rule: alert_rule,
      org: org
    } do
      bad_access_token = "qwerty1234567uiop"
      {:ok, alert_rule} = AlertRules.create(alert_rule)

      # added bad access token here
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        delete(
          conn,
          Routes.alert_rules_path(conn, :delete, org.id, alert_rule.id)
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
    setup :setup_alert_rules

    test "list alert rules", %{conn: conn, alert_rule: alert_rule, org: org} do
      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      AlertRules.create(alert_rule)

      conn = get(conn, Routes.alert_rules_path(conn, :index, org.id, params))

      response = conn |> json_response(200)
      assert response["alert_rules"]
    end

    test "fails if invalid token in authorization header", %{
      conn: conn,
      org: org
    } do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn = get(conn, Routes.alert_rules_path(conn, :index, org.id, params))

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end
  end

  def setup_alert_rules(_context) do
    sensor = insert(:sensor)
    [param1, _param2] = fetch_parameters(sensor.sensor_type.parameters)
    [user1, user2, user3] = insert_list(3, :user)

    alert_rule = %{
      entity: "sensor",
      rule_name: "Temperature",
      entity_id: sensor.id,
      policy_name: "Elixir.AcqdatCore.Alerts.Policies.RangeBased",
      entity_parameters: param1,
      uuid: UUID.uuid1(:hex),
      communication_medium: ["in-app, sms, e-mail"],
      slug: Slugger.slugify(random_string(12)),
      rule_parameters: %{lower_limit: 10, upper_limit: 20},
      recepient_ids: [0, user1.id, user2.id],
      assignee_ids: [user3.id],
      policy_type: ["user"],
      severity: "Low",
      status: "enable",
      app: "iot_manager",
      project_id: sensor.project_id,
      org_id: sensor.org_id,
      creator_id: user1.id
    }

    [alert_rule: alert_rule]
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end

  defp fetch_parameters(parameters) do
    Enum.reduce(parameters, [], fn param, acc ->
      acc ++ [Map.from_struct(param)]
    end)
  end
end
