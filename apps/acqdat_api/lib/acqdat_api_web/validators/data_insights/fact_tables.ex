defmodule AcqdatApiWeb.Validators.DataInsights.FactTables do
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
      org_id!: :integer,
      name!: :string,
      project_id!: :integer
    })
  )
end
