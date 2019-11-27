defmodule AcqdatCore.Model.SensorNotification do
  @moduledoc """
  Models functions for configuring data for sensor notifications.
  """

  alias AcqdatCore.Schema.SensorNotifications, as: SNotifications
  alias AcqdatCore.Repo
  alias AcqdatCore.Notification.PolicyMap

  def create(params) do
    changeset = SNotifications.changeset(%SNotifications{}, params)
    Repo.insert(changeset)
  end

  def update(notification, params) do
    changeset = SNotifications.changeset(notification, params)
    Repo.update(changeset)
  end

  def get(id) do
    case Repo.get(SNotifications, id) do
      nil ->
        {:error, "not found"}

      notification ->
        notification = Repo.preload(notification, sensor: [:device, :sensor_type])
        {:ok, notification}
    end
  end

  def get_by_sensor(sensor_id) do
    Repo.get_by(SNotifications, sensor_id: sensor_id)
  end

  def get_all() do
    SNotifications |> Repo.all() |> Repo.preload(sensor: :device)
  end

  def delete(id) do
    SNotifications
    |> Repo.get(id)
    |> Repo.delete()
  end

  def get_policies() do
    policies = PolicyMap.policies()

    Enum.map(policies, fn policy ->
      module = String.to_existing_atom(policy)
      rule_name = module.rule_name
      {rule_name, policy}
    end)
  end

  def get_policies_with_preferences() do
    policies = PolicyMap.policies()

    Enum.map(policies, fn policy ->
      module = String.to_existing_atom(policy)
      rule_name = module.rule_name
      preferences = policy_preferences(policy, %{})
      %{rule_name: rule_name, policy_name: policy, preferences: preferences}
    end)
  end

  def policy_preferences(module, params) do
    module = String.to_existing_atom(module)
    module.rule_preferences(params)
  end
end
