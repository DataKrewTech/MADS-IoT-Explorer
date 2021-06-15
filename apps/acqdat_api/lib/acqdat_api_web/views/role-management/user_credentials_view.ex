defmodule AcqdatApiWeb.RoleManagement.UserCredentialsView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.RoleManagement.UserCredentialsView

  def render("user_credentials.json", %{user_details: user_credentials}) do
    %{
      id: user_credentials.id,
      email: user_credentials.email,
      first_name: user_credentials.first_name,
      last_name: user_credentials.last_name,
      phone_number: user_credentials.phone_number,
      avatar: user_credentials.avatar,
      metadata: user_credentials.metadata && Map.from_struct(user_credentials.metadata),
      user_setting:
        render_one(user_credentials.user_setting, UserCredentialsView, "user_setting.json")
    }
  end

  def render("user_setting.json", setting) do
    %{
      user_setting_id: setting.user_credentials.id,
      visual_settings: Map.from_struct(setting.user_credentials.visual_settings),
      data_settings: Map.from_struct(setting.user_credentials.data_settings)
    }
  end
end
