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

  defparams(
    verify_create_params(%{
      token!: :string,
      first_name: :string,
      last_name: :string,
      password!: :string,
      password_confirmation!: :string
    })
  )
end
