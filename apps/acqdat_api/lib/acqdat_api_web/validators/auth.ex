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
    verify_org_login_credentials(%{
      org_id!: :integer
    })
  )

  defparams(
    verify_register_credentials(%{
      first_name!: :string,
      last_name!: :string,
      email!: :string,
      phone_number!: :string,
      org_name!: :string,
      org_url!: :string,
      user_metadata!: :map
    })
  )

  defparams(
    verify_refresh_params(%{
      access_token!: :string
    })
  )

  defparams(
    verify_sign_out_params(%{
      access_token!: :string,
      refresh_token!: :string
    })
  )

  defparams(
    verify_validate_params(%{
      password!: :string,
      org_id!: :integer
    })
  )
end
