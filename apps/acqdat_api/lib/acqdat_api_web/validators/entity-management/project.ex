defmodule AcqdatApiWeb.Validators.EntityManagement.Project do
  use Params

  defparams(
    verify_project(%{
      name!: :string,
      description: :string,
      avatar: :string,
      metadata: :map,
      location: :map,
      archived: [field: :boolean, default: false],
      version: [field: :integer, default: 1],
      start_date: :utc_datetime,
      org_id!: :integer,
      creator_id!: :integer,
      lead_ids: [field: {:array, :integer}, default: []],
      user_ids: [field: {:array, :integer}, default: []]
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer,
      org_id!: :integer
    })
  )
end
