defmodule AcqdatApiWeb.Validators.RoleManagement.Invitation do
  use Params

  defparams(
    verify_create_params(%{
      email!: :string,
      assets: {:array, :map},
      apps: {:array, :map},
      org_id!: :integer,
      role_id!: :integer,
      group_ids: [field: {:array, :integer}, default: []],
      policies: [field: {:array, :map}, default: []]
    })
  )

  defparams(
    verify_index_params(%{
      org_id: :string,
      page_size: :integer,
      page_number: :integer
    })
  )
end
