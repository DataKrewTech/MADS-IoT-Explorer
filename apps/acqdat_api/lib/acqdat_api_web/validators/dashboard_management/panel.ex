defmodule AcqdatApiWeb.Validators.DashboardManagement.Panel do
  use Params

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer,
      org_id!: :integer,
      dashboard_id!: :integer
    })
  )

  defparams(
    verify_create(%{
      org_id!: :integer,
      dashboard_id!: :integer,
      name!: :string,
      description: :string,
      settings: :map,
      widget_layouts: :map,
      filter_metadata: :map
    })
  )
end
