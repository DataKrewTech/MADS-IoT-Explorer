defmodule AcqdatApiWeb.Validators.Asset do
  use Params

  defparams(
    verify_asset(%{
      owner_id: :integer,
      creator_id!: :integer,
      asset_category_id: :integer,
      org_id!: :integer,
      image_url: :string,
      mapped_parameters: {:array, :map},
      description: :string,
      metadata: :map,
      rgt: :integer,
      properties: {:array, :string},
      lft: :integer,
      parent_id: :integer,
      name: :string
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer
    })
  )
end
