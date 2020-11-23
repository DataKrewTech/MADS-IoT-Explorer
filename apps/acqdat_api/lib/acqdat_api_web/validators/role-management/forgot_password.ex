defmodule AcqdatApiWeb.Validators.RoleManagement.ForgotPassword do
  use Params

  defparams(
    verify_user_id(%{
      user_id!: :integer
    })
  )
end
