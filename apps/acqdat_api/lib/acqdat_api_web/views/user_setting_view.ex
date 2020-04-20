defmodule AcqdatApiWeb.UserSettingView do
  use AcqdatApiWeb, :view

  def render("user_setting.json", %{setting: setting}) do
    %{
      id: setting.id,
      user_id: setting.user_id,
      visual_settings: Map.from_struct(setting.visual_settings),
      data_settings: Map.from_struct(setting.data_settings)
    }
  end
end
