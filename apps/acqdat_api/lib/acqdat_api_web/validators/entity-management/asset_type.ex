defmodule AcqdatApiWeb.Validators.EntityManagement.AssetType do
  use Params

  defparams(
    verify_asset_type_params(%{
      name!: :string,
      description: :string,
      metadata: [field: {:array, :map}, default: []],
      parameters: [field: {:array, :map}, default: []],
      org_id!: :integer,
      project_id!: :integer,
      sensor_type_present: [field: :boolean, default: false],
      sensor_type_uuid: :string
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
