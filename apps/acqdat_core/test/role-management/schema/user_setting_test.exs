defmodule AcqdatCore.Schema.RoleManagement.UserSettingTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory

  alias AcqdatCore.Schema.RoleManagement.UserSetting

  describe "changeset/2" do
    setup do
      user_credentials = insert(:user_credentials)

      [user_credentials: user_credentials]
    end

    test "returns a valid changeset", context do
      %{user_credentials: user_credentials} = context

      params = %{
        user_credentials_id: user_credentials.id,
        visual_settings: %{
          recently_visited_apps: ["data_cruncher", "support", "settings", "dashboard"],
          taskbar_pos: "left",
          desktop_wallpaper: "default.png"
        },
        data_settings: %{
          latitude: 11.2,
          longitude: 20.22
        }
      }

      %{valid?: validity} = UserSetting.changeset(%UserSetting{}, params)
      assert validity
    end

    test "returns error changeset on empty params" do
      changeset = UserSetting.changeset(%UserSetting{}, %{})

      assert %{user_credentials_id: ["can't be blank"]} == errors_on(changeset)
    end
  end
end
