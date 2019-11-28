defmodule AcqdatApiWeb.SensorNotificationView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.SensorNotificationView
  alias AcqdatApiWeb.SensorView
 
  def render("index.json", sensor_notification) do
    %{
      sensor_notification: render_many(sensor_notification.entries, SensorNotificationView, "sensor_notification_with_preloads.json"),
      page_number: sensor_notification.page_number,
      page_size: sensor_notification.page_size,
      total_entries: sensor_notification.total_entries,
      total_pages: sensor_notification.total_pages
    }
  end

  def render("sensor_notification_with_preloads.json", %{sensor_notification: sensor_notification}) do
    %{
      rule_values: sensor_notification.rule_values,
      sensor_id: sensor_notification.sensor_id,
      alarm_status: sensor_notification.alarm_status, 
      sensor: render_one(sensor_notification.sensor, SensorView, "sensor.json")
    }
  end
  
  def render("sensor_notification.json", %{sensor_notification: sensor_notification}) do
    %{
      rule_values: sensor_notification.rule_values,
      sensor_id: sensor_notification.sensor_id,
      alarm_status: sensor_notification.alarm_status 
    }
  end
end