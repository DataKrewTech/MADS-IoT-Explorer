defmodule AcqdatApiWeb.Validators.EntityManagement.Asset do
  use Params

  defparams(
    verify_asset(%{
      owner_id: :integer,
      creator_id!: :integer,
      org_id!: :integer,
      image_url: :string,
      mapped_parameters: [field: {:array, :map}, default: []],
      description: :string,
      metadata: [field: {:array, :map}, default: []],
      rgt: :integer,
      properties: {:array, :string},
      lft: :integer,
      parent_id: :integer,
      name!: :string,
      project_id!: :integer,
      asset_type_id!: :integer
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
