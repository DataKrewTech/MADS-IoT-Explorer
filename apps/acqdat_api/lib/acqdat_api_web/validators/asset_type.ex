defmodule AcqdatApiWeb.Validators.AssetType do
  use Params

  defparams(
    verify_asset_params(%{
      name!: :string,
      description: :string,
      metadata: {:array, :map},
      parameters!: {:array, :map},
      org_id!: :integer,
      sensor_type_present: [field: :boolean, default: false],
      sensor_type_uuid: :string
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer
    })
  )
end
