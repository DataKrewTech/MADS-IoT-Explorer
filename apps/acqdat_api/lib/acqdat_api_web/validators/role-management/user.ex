defmodule AcqdatApiWeb.Validators.RoleManagement.User do
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

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer,
      org_id!: :integer
    })
  )
end
