defmodule AcqdatApiWeb.Validators.DashboardManagement.CommandWidget do
  use Params

  defparams(
    verify_params(%{
      label!: :string,
      org_id!: :integer,
      module!: :string,
      data_settings: :map,
      visual_settings: :map,
      properties: :map,
      gateway_id!: :integer,
      panel_id!: :integer
    })
  )
end
