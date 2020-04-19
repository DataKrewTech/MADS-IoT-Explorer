defmodule AcqdatApiWeb.Validators.Team do
  use Params

  defparams(
    verify_create_params(%{
      name!: :string,
      team_lead_id: :integer,
      enable_tracking: :boolean,
      org_id: :integer,
      assets: {:array, :map},
      apps: {:array, :map},
      users: {:array, :map}
    })
  )

  defparams(
    verify_index_params(%{
      page_size: :integer,
      page_number: :integer
    })
  )
end
