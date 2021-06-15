defmodule AcqdatApiWeb.Validators.RoleManagement.UserCredentials do
  use Params

  defparams(
    verify_update_credentials_params(%{
      first_name: :string,
      last_name: :string,
      metadata: :map,
      user_setting: :map,
      avatar: :string
    })
  )
end
