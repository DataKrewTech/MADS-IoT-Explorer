defmodule AcqdatCore.Model.UserSettingTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.UserSetting, as: UserSettingModel

  describe "create/1" do
    test "creates a user_setting with supplied params" do
      user = insert(:user)

      params = %{
        user_id: user.id,
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

      assert {:ok, _usersetting} = UserSettingModel.create(params)
    end

    test "fails if user_id is not present" do
      params = %{
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

      assert {:error, changeset} = UserSettingModel.create(params)
      assert %{user_id: ["can't be blank"]} == errors_on(changeset)
    end
  end

  describe "get/1" do
    test "returns a particular user_setting" do
      user_setting = insert(:user_setting)

      {:ok, result} = UserSettingModel.get(user_setting.id)
      assert not is_nil(result)
      assert result.id == user_setting.id
    end

    test "returns error not found, if setting is not present" do
      {:error, result} = UserSettingModel.get(-1)
      assert result == "not found"
    end
  end
end
