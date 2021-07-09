defmodule AcqdatCore.Alerts.Model.AlertRulesTest do
  @moduledoc """
    For testing alert rules model
  """
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  alias AcqdatCore.Alerts.Model.AlertRules, as: ARModel
  import AcqdatCore.Support.Factory

  describe "create/1" do
    setup :setup_alert_rules

    test "with valid params", %{alert_rule: alert_rule} do
      assert {:ok, _alert_rule} = ARModel.create(alert_rule)
    end

    test "with invalid params" do
      assert {:error, _alert_rule} = ARModel.create(%{})
    end
  end

  describe "update/2" do
    setup :setup_alert_rules

    test "with valid params", %{alert_rule: alert_rule} do
      {:ok, alert_rule} = ARModel.create(alert_rule)
      assert {:ok, _alert_rule} = ARModel.update(alert_rule, %{policy_type: ["project"]})
    end

    test "with invalid params", %{alert_rule: alert_rule} do
      {:ok, alert_rule} = ARModel.create(alert_rule)
      assert {:error, _} = ARModel.update(alert_rule, %{creator_id: nil})
    end
  end

  describe "delete/1" do
    setup :setup_alert_rules

    test "with valid params", %{alert_rule: alert_rule} do
      {:ok, alert_rule} = ARModel.create(alert_rule)
      assert {:ok, _} = ARModel.delete(alert_rule)
    end
  end

  def setup_alert_rules(_) do
    sensor = insert(:sensor)
    [param1, _] = fetch_parameters(sensor.sensor_type.parameters)
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
      # here 0 is added because this is getting converted into charlist
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
