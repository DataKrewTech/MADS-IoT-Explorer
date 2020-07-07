defmodule AcqdatApiWeb.Validators.DashboardManagement.WidgetInstance do
  use Params

  defparams(
    verify_create(%{
      label!: :string,
      org_id!: :integer,
      widget_id!: :integer,
      dashboard_id!: :integer,
      series: [field: {:array, :map}, default: []]
    })
  )
end
