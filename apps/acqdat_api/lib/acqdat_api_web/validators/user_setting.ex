defmodule AcqdatApiWeb.Validators.UserSetting do
  use Params

  defparams(
    verify_user_setting_params(%{
      user_id!: :integer,
      visual_settings!: :map,
      data_settings!: :map
    })
  )
end
