defmodule AcqdatCore.Alerts.AlertCreation do
  @moduledoc """
  Contains logic of creation of an alert from alert rule.
  This module will receive data in object from data parser which will contain ids and the respective parameters
  to be stored. Example:-
  %{
    25 ->
      [
        %{
          parameter_uuid: uuid1,
          value: value1
        },
        %{
          parameter_uuid: uuid2,
          value: value2
        }
      ]
  }
  25 is the entity id and will be used to check alert rule existence for this id
  and parameter and it's valus is the one which will be used detect rule eligibility.
  """

  alias AcqdatCore.Alerts.Model.AlertRules
  alias AcqdatCore.Alerts.Model.Alert
  alias AcqdatCore.Mailer.AlertNotification
  alias AcqdatCore.Mailer
  alias AcqdatCore.Model.RoleManagement.User
  alias AcqdatCore.Alerts.Server
  alias Notifications

  @doc """
  For calling server for starting out alert creation
  """
  def gateway_alert(data) do
    GenServer.cast(Server, {:gateway_alert, data})
  end

  def sensor_alert(data) do
    GenServer.cast(Server, {:sensor_alert, data})
  end

  @doc """
  Receives data from dataparser module and for each entity ID will check if a alert rule exist or not.
  """
  def traverse_ids(data, "sensor") do
    Enum.each(data, fn {key, parameters} ->
      check_alert_rule(key, "sensor")
      |> case do
        nil -> :no_reply
        alert_rule -> check_parameter(alert_rule, parameters)
      end
    end)
  end

  # Receives data from dataparser module and for each entity ID will check if a alert rule exist or not.
  def traverse_ids(data, "gateway") do
    Enum.each(data, fn {key, parameters} ->
      check_alert_rule(key, "gateway")
      |> case do
        nil -> :no_reply
        alert_rule -> check_parameter(alert_rule, parameters)
      end
    end)
  end

  # Check for the availability of alert rule for that specific entity
  defp check_alert_rule(entity_id, entity) do
    AlertRules.check_rule(entity_id, entity)
  end

  # Check for the parameter for that entity if that parameter is a valid parameter for which alert rule is created.

  defp check_parameter(alert_rule, parameters) do
    entity_parameter = alert_rule.entity_parameters

    Enum.each(parameters, fn parameter ->
      case parameter.uuid == entity_parameter.uuid do
        true -> check_eligibility({:ok, parameter, alert_rule})
        false -> check_eligibility({:error, false})
      end
    end)
  end

  # check the eligibility of that parameter with the given policy

  defp check_eligibility({:ok, parameter, alert_rule}) do
    case alert_rule.policy_name.eligible?(alert_rule.rule_parameters, parameter.value) do
      true ->
        :noreply

      false ->
        data_manifest(alert_rule, parameter)
        |> create_alert(alert_rule)
    end
  end

  # if eligibility doesn't matches then just return noreply

  defp check_eligibility({:error, false}) do
    {:error, :noreply}
  end

  # Create alert object with all the valid parameters

  defp data_manifest(alert_rule, parameter) do
    %{
      name: alert_rule.rule_name,
      description: alert_rule.description,
      policy_name: alert_rule.policy_name.rule_name(),
      policy_module_name: alert_rule.policy_name,
      app: alert_rule.app,
      entity_name: alert_rule.entity,
      entity_id: alert_rule.entity_id,
      communication_medium: alert_rule.communication_medium,
      recepient_ids: alert_rule.recepient_ids,
      assignee_ids: alert_rule.assignee_ids,
      severity: alert_rule.severity,
      status: "un_resolved",
      creator_id: alert_rule.creator_id,
      project_id: alert_rule.project_id,
      org_id: alert_rule.org_id,
      rule_parameters: [
        %{
          name: parameter.name,
          data_type: parameter.data_type,
          entity_parameter_uuid: parameter.uuid,
          entity_parameter_name: parameter.name,
          value: parameter.value
        }
      ]
    }
  end

  def create_alert(params, alert_rule) do
    Task.start_link(fn ->
      case Alert.create(params) do
        {:ok, alert} ->
          {:ok, severity_code} = AlertSeverityEnum.dump(alert.severity)
          alert = Map.put_new(alert, :severity_code, severity_code)

          app =
            Atom.to_string(alert.app)
            |> String.split("_")
            |> Enum.reduce([], fn x, acc -> acc ++ [String.capitalize(x)] end)
            |> Enum.reduce("", fn x, acc -> acc <> x <> " " end)
            |> String.trim_trailing(" ")

          alert = Map.put_new(alert, :alert_app_name, app)
          Notifications.send_notifications(alert, alert_rule, "twilio")

        {:error, _error} ->
          {:error, :noreply}
      end
    end)
  end
end
