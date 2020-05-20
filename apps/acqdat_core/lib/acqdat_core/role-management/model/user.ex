defmodule AcqdatCore.Model.RoleManagement.User do
  @moduledoc """
  Exposes APIs for handling user related fields.
  """

  alias AcqdatCore.Schema.EntityManagement.Asset
  alias AcqdatCore.Schema.RoleManagement.{User, App}
  alias AcqdatCore.Repo
  import Ecto.Query

  @doc """
  Creates a User with the supplied params.

  Expects following keys.
  - `first_name`
  - `last_name`
  - `email`
  - `password`
  - `password_confirmation`
  """
  @spec create(map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    changeset = User.changeset(%User{}, params)
    Repo.insert(changeset)
  end

  @doc """
  Returns a user by the supplied id.
  """
  def get(id) when is_integer(id) do
    case Repo.get(User, id) |> Repo.preload([:user_setting]) do
      nil ->
        {:error, "not found"}

      user ->
        {:ok, user}
    end
  end

  @doc """
  Returns a user by the supplied email.
  """
  def get(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Deletes a User.

  Expects `user_id` as the argument.
  """
  @spec delete(non_neg_integer) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def delete(user) do
    user |> Repo.delete()
  end

  @doc """
  Update a User.

  Expects `user` and update parameters as the arguments
  """
  def update_user(%User{} = user, params) do
    changeset = User.update_changeset(user, params)

    case Repo.update(changeset) do
      {:ok, user} -> {:ok, user |> Repo.preload(:role)}
      {:error, message} -> {:error, message}
    end
  end

  def set_invited_to_false(%User{} = user) do
    user
    |> Ecto.Changeset.change(%{is_invited: false})
    |> Repo.update()
  end

  def set_asset(user, assets) do
    asset_ids = Enum.map(assets || [], & &1["id"])

    user_assets =
      Asset
      |> where([asset], asset.id in ^asset_ids)
      |> where([asset], asset.org_id == ^user.org_id)
      |> Repo.all()

    user
    |> User.associate_asset_changeset(user_assets)
    |> Repo.update()
  end

  def set_apps(user, apps) do
    app_ids = Enum.map(apps || [], & &1["id"])

    user_apps =
      App
      |> where([app], app.id in ^app_ids)
      |> Repo.all()

    user
    |> User.associate_app_changeset(user_apps)
    |> Repo.update()
  end
end
