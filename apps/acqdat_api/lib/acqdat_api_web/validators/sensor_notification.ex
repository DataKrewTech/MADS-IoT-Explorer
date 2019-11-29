defmodule AcqdatApiWeb.Validators.SensorNotification do
  use Params

  defparams(
    verify_sensor_notification_params(%{
      rule_values!: :map,
      sensor_id!: :integer,
      alarm_status: :boolean
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer
    })
  )
end
