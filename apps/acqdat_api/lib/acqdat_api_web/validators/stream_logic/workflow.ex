defmodule AcqdatApiWeb.Validators.StreamLogic.Workflow do

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
    verify_create_params(%{
      name!: :string,
      digraph!: :map,
      enabled: :boolean,
      description: :string,
      metadata: :map,
      project_id: :integer,
      org_id: :integer
    })
  )
end
