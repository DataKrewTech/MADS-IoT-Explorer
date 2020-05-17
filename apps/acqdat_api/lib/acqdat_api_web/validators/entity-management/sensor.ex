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
      page_number: :integer,
      org_id: :integer,
      project_id: :integer
    })
  )

  defparams(
    verify_sensor_create_params(%{
      sensor_type_id: :integer,
      org_id!: :integer,
      description: :string,
      metadata: :map,
      parent_id: :integer,
      parent_type: :string,
      name: :string,
      project_id!: :integer
    })
  )
end
