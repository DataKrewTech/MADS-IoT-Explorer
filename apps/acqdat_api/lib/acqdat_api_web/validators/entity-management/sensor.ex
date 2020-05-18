defmodule AcqdatApiWeb.Validators.EntityManagement.Sensor do
  use Params

  defparams(
    verify_sensor_params(%{
      name!: :string,
      parent_id!: :integer,
      metadata: :map,
      parent_type: :string,
      org_id!: :integer,
      project_id!: :integer,
      gateway_id: :integer,
      sensor_type_id!: :integer
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer
    })
  )
end
