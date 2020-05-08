defmodule AcqdatApiWeb.Validators.RoleManagement.Invitation do
  use Params

  defparams(
    verify_create_params(%{
      email!: :string,
      assets: {:array, :map},
      apps: {:array, :map},
      org_id!: :string,
      role_id!: :integer
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
