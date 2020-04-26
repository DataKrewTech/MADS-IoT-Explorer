defmodule AcqdatApiWeb.Validators.User do
  use Params

  defparams(
    verify_assets_params(%{
      assets!: {:array, :map}
    })
  )

  defparams(
    verify_apps_params(%{
      apps!: {:array, :map}
    })
  )
end
