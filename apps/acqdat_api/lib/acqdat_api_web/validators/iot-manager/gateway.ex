defmodule AcqdatApiWeb.Validators.IotManager.Gateway do
  use Params

  defparams(
    verify_gateway(%{
      serializer: :map,
      current_location: :map,
      channel!: :string,
      static_data: [field: {:array, :map}, default: []],
      streaming_data: [field: {:array, :map}, default: []],
      access_token!: :string,
      org_id!: :integer,
      image_url: :string,
      description: :string,
      parent_id!: :integer,
      parent_type!: :string,
      name!: :string,
      project_id!: :integer,
      mapped_parameters: :map
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer,
      org_id!: :integer,
      project_id!: :integer
    })
  )
end
