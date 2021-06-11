defmodule AcqdatApiWeb.Validators.RoleManagement.Requests do
  use Params

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer
    })
  )
end
