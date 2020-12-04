defmodule AcqdatApiWeb.Validators.RoleManagement.ForgotPassword do
  use Params

  defparams(
    verify_email(%{
      email!: :string
    })
  )
end
