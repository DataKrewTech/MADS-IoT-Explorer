defmodule AcqdatApiWeb.Validators.Invitation do
  use Params

  defparams(
    verify_create_params(%{
      email!: :string,
      assets: {:array, :map},
      apps: {:array, :map},
      org_id!: :string
    })
  )
end
