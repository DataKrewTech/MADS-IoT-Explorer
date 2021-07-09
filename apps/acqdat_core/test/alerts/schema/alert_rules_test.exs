defmodule AcqdatCore.Alerts.Schema.AlertRulesTest do
  @moduledoc """
  Testing module for alert rules schema
  """
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  alias AcqdatCore.Alerts.Schema.AlertRules
  import AcqdatCore.Support.Factory

  describe "changeset/2" do
    setup :setup_alert_rules

    test "returns a valid changeset", %{alert_rule: alert_rule} do
      %{valid?: validity} = AlertRules.changeset(%AlertRules{}, alert_rule)
      assert validity
    end

    test "returns invalid changeset for missing required params" do
      %{valid?: validity} = changeset = AlertRules.changeset(%AlertRules{}, %{})
      refute validity

      assert %{
               creator_id: ["can't be blank"],
               entity: ["can't be blank"],
               entity_id: ["can't be blank"],
               policy_name: ["can't be blank"],
               rule_parameters: ["can't be blank"],
               app: ["can't be blank"],
               communication_medium: ["can't be blank"],
               org_id: ["can't be blank"],
               recepient_ids: ["can't be blank"],
               severity: ["can't be blank"],
               status: ["can't be blank"]
             } = errors_on(changeset)
    end
  end

  def setup_alert_rules(_) do
    sensor = insert(:sensor)
    [param1, _param2] = fetch_parameters(sensor.sensor_type.parameters)
    [user1, user2, user3] = insert_list(3, :user)

    alert_rule = %{
      rule_name: "Temperature",
      entity: "sensor",
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
