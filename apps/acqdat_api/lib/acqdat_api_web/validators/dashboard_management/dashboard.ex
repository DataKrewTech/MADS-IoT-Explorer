defmodule AcqdatApiWeb.Validators.DashboardManagement.Dashboard do
  use Params

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer,
      org_id!: :integer,
      type: :string
    })
  )

  defparams(
    verify_create(%{
      org_id!: :integer,
      name!: :string,
      avatar: :string,
      description: :string,
      settings: :map,
      widget_layouts: :map,
      creator_id!: :integer
    })
  )
end
