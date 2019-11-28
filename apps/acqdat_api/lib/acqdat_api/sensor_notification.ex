defmodule AcqdatApi.SensorNotification do
  alias AcqdatCore.Schema.SensorNotifications
  alias AcqdatCore.Model.SensorNotification, as: SensorNotificationModel
  import AcqdatApiWeb.Helpers

  def create(params) do
    %{
      rule_values: rule_values,
      alarm_status: alarm_status,
      sensor_id: sensor_id
    } = params

    verify_sensor(
      SensorNotificationModel.create(%{
        rule_values: rule_values,
        alarm_status: alarm_status,
        sensor_id: sensor_id
      })
    )
  end

  defp verify_sensor({:ok, sensor_notification}) do
    {:ok,
     %{
        rule_values: sensor_notification.rule_values,
        alarm_status: sensor_notification.alarm_status,
        sensor_id: sensor_notification.sensor_id
     }}
  end

  defp verify_sensor({:error, sensor_notification}) do
    {:error, %{error: extract_changeset_error(sensor_notification)}}
  end
end
