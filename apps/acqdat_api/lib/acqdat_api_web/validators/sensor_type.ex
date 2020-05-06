defmodule AcqdatApiWeb.Validators.SensorType do
  use Params

  defparams(
    verify_sensor_params(%{
      name!: :string,
      description: :string,
      metadata: :map,
      parameters!: {:array, :map},
      org_id!: :integer
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer
    })
  )
end
