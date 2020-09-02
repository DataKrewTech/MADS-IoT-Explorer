defmodule AcqdatApiWeb.Validators.DashboardExport.DashboardExport do
  use Params

  defparams(
    verify_params(%{
      is_secure!: [field: :boolean, default: false],
      dashboard_id!: :integer,
      password: :string
    })
  )
end
