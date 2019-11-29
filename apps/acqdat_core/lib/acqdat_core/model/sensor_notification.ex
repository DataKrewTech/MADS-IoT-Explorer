defmodule AcqdatCore.Model.SensorNotification do
  @moduledoc """
  Models functions for configuring data for sensor notifications.
  """
  import Ecto.Query
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

  def get_all(%{page_size: page_size, page_number: page_number}, preloads) do
    paginated_sensor_notification_data =
      SNotifications |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    sensor_notification_data_with_preloads =
      paginated_sensor_notification_data.entries |> Repo.preload(preloads)

    %{
      entries: sensor_notification_data_with_preloads,
      page_number: paginated_sensor_notification_data.page_number,
      page_size: paginated_sensor_notification_data.page_size,
      total_entries: paginated_sensor_notification_data.total_entries,
      total_pages: paginated_sensor_notification_data.total_pages
    }
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
