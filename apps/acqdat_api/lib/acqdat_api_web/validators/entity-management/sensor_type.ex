defmodule AcqdatApiWeb.Validators.EntityManagement.SensorType do
  use Params

  defparams(
    verify_sensor_params(%{
      name!: :string,
      description: :string,
      metadata: {:array, :map},
      parameters!: {:array, :map},
      project_id!: :integer,
      org_id!: :integer,
      generated_by: [field: :string, default: "user"]
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer
    })
  )
end
