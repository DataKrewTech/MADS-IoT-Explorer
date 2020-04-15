defmodule AcqdatApiWeb.Validators.User do
  use Params

  defparams(
    verify_user_assets_params(%{
      asset_ids!: {:array, :string}
    })
  )
end
