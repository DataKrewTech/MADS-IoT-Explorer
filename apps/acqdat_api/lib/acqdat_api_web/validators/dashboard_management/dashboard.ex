defmodule AcqdatApiWeb.Validators.DashboardManagement.Dashboard do
  use Params

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer,
      org_id!: :integer,
      project_id!: :integer
    })
  )

  defparams(
    verify_create(%{
      project_id!: :integer,
      org_id!: :integer,
      name!: :string,
      description: :string,
      settings: :map
    })
  )
end
