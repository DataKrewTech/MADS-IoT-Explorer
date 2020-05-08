defmodule AcqdatApiWeb.Validators.RoleManagement.Team do
  use Params

  defparams(
    verify_create_params(%{
      name!: :string,
      description: :string,
      team_lead_id: :integer,
      enable_tracking: :boolean,
      org_id: :string,
      assets: {:array, :map},
      apps: {:array, :map},
      members: {:array, :map}
    })
  )

  defparams(
    verify_assets_params(%{
      assets!: {:array, :map}
    })
  )

  defparams(
    verify_apps_params(%{
      apps!: {:array, :map}
    })
  )

  defparams(
    verify_members_params(%{
      members!: {:array, :map}
    })
  )

  defparams(
    verify_update_params(%{
      team_lead_id: :integer,
      enable_tracking: :boolean,
      description: :string
    })
  )

  defparams(
    verify_index_params(%{
      org_id: :string,
      page_size: :integer,
      page_number: :integer
    })
  )
end
