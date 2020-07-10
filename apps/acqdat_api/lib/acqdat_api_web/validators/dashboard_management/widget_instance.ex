defmodule AcqdatApiWeb.Validators.DashboardManagement.WidgetInstance do
  use Params

  defparams(
    verify_create(%{
      label!: :string,
      org_id!: :integer,
      widget_id!: :integer,
      dashboard_id!: :integer,
      settings: :map,
      visual_prop: :map,
      series: [field: {:array, :map}, default: []]
    })
  )
end
