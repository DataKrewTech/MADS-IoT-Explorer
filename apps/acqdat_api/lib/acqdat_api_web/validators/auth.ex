defmodule AcqdatApiWeb.Validators.Auth do
  @moduledoc """
  Exposes validator functions to validate params for auth rleated APIs.
  """

  use Params

  defparams(
    verify_login_credentials(%{
      email!: :string,
      password!: :string
    })
  )

  defparams(
    verify_refresh_params(%{
      refresh_token!: :string
    })
  )

  defparams(
    verify_sign_out_params(%{
      access_token!: :string,
      refresh_token!: :string
    })
  )
end
