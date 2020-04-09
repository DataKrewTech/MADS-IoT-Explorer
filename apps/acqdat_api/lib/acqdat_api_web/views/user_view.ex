defmodule AcqdatApiWeb.UserView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.UserView

  def render("user_details.json", %{user_details: user_details}) do
    %{
      id: user_details.id,
      email: user_details.email,
      first_name: user_details.first_name,
      last_name: user_details.last_name,
      user_setting: render_one(user_details.user_setting, UserView, "user_setting.json")
    }
  end

  def render("user_setting.json", setting) do
    %{
      user_setting_id: setting.user.id,
      visual_settings: Map.from_struct(setting.user.visual_settings),
      data_settings: Map.from_struct(setting.user.data_settings)
    }
  end
end
