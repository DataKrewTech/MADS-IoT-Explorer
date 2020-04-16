defmodule AcqdatApiWeb.Validators.Invitation do
  use Params

  defparams(
    verify_invitation_params(%{
      email!: :string,
      assets: {:array, :map},
      apps: {:array, :map}
    })
  )
end
