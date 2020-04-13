defmodule AcqdatApi.UserSetting do
  alias AcqdatCore.Model.UserSetting, as: UserSettingModel
  import AcqdatApiWeb.Helpers

  def create(params) do
    %{
      visual_settings: visual_settings,
      data_settings: data_settings,
      user_id: user_id
    } = params

    verify_user_setting(
      UserSettingModel.create(%{
        visual_settings: visual_settings,
        data_settings: data_settings,
        user_id: user_id
      })
    )
  end

  def update(user_setting, params) do
    %{
      visual_settings: visual_settings,
      data_settings: data_settings,
      user_id: user_id
    } = params

    verify_user_setting(
      UserSettingModel.update(user_setting, %{
        visual_settings: visual_settings,
        data_settings: data_settings,
        user_id: user_id
      })
    )
  end

  defp verify_user_setting({:ok, user_setting}) do
    {:ok,
     %{
       visual_settings: user_setting.visual_settings,
       data_settings: user_setting.data_settings,
       user_id: user_setting.user_id,
       id: user_setting.id
     }}
  end

  defp verify_user_setting({:error, user_setting}) do
    {:error, %{error: extract_changeset_error(user_setting)}}
  end

  def get(user_id) do
    UserSettingModel.get(user_id)
  end
end
