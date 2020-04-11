defmodule AcqdatApiWeb.Validators.Sensor do
  use Params

  defparams(
    verify_sensor_params(%{
      name!: :string
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer
    })
  )
end
