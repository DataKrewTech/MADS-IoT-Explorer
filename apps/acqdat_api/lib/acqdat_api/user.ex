defmodule AcqdatApi.User do
  alias AcqdatCore.Model.User, as: UserModel
  import AcqdatApiWeb.Helpers

  def get(user_id) do
    UserModel.get(user_id)
  end

  def set_asset(user, %{assets: assets}) do
    verify_user_assets(UserModel.set_asset(user, assets))
  end

  def set_apps(user, %{apps: apps}) do
    verify_user_apps(UserModel.set_apps(user, apps))
  end

  defp verify_user_assets({:ok, user}) do
    {:ok,
     %{
       assets: user.assets,
       email: user.email,
       id: user.id
     }}
  end

  defp verify_user_assets({:error, user}) do
    {:error, %{error: extract_changeset_error(user)}}
  end

  defp verify_user_apps({:ok, user}) do
    {:ok,
     %{
       apps: user.apps,
       email: user.email,
       id: user.id
     }}
  end

  defp verify_user_apps({:error, user}) do
    {:error, %{error: extract_changeset_error(user)}}
  end
end
