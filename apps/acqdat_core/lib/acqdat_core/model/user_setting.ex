defmodule AcqdatCore.Model.UserSetting do
  @moduledoc """
  Exposes APIs for handling user_setting related fields.
  """

  alias AcqdatCore.Schema.UserSetting
  alias AcqdatCore.Repo

  @doc """
  Creates a UserSetting with the supplied params.

  Expects following keys.
  - user_id
  - visual_settings
    - taskbar_pos
    - recently_visited_apps
    - desktop_wallpaper
    - desktop_app_shortcuts
  - data_settings
    - last_login_at
    - latitude
    - longitude

  """
  def create(params) do
    changeset = UserSetting.changeset(%UserSetting{}, params)
    Repo.insert(changeset)
  end

  @doc """
  Updates UserSetting
  """
  def update(setting, params) do
    changeset = UserSetting.update_changeset(setting, params)
    Repo.update(changeset)
  end

  @doc """
  Returns user_setting by the supplied id.
  """
  def get(id) when is_integer(id) do
    case Repo.get(UserSetting, id) do
      nil ->
        {:error, "not found"}

      user_setting ->
        {:ok, user_setting}
    end
  end

  @doc """
  Deletes UserSetting.

  Expects `user_setting_id` as the argument.
  """
  def delete(id) when is_integer(id) do
    Repo.get_by(UserSetting, id: id) |> Repo.delete()
  end
end
