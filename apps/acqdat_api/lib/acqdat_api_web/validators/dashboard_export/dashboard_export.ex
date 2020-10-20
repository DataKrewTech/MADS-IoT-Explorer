defmodule AcqdatApiWeb.Validators.DashboardExport.DashboardExport do
  use Params

  defparams(
    verify_params(%{
      is_secure!: [field: :boolean, default: false],
      dashboard_id!: :integer,
      password: :string
    })
  )

  defparams(
    verify_update_params(%{
      is_secure!: [field: :boolean, default: false],
      password: :string
    })
  )
end
