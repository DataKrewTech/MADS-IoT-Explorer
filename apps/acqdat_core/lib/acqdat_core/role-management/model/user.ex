defmodule AcqdatCore.Model.RoleManagement.User do
  @moduledoc """
  Exposes APIs for handling user related fields.
  """

  alias AcqdatCore.Schema.EntityManagement.{Asset, Organisation}
  alias AcqdatCore.Schema.RoleManagement.{User, App}
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.Helper, as: ModelHelper
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

  def get_for_view(user_ids) do
    query =
      from(user in User,
        where: user.id in ^user_ids,
        preload: [:user_setting, :org, :role]
      )

    Repo.all(query)
  end

  def get_by_email(email) when is_binary(email) do
    case Repo.get_by(User, email: email) do
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
  Returns the list of user for the index api
  """

  def get_all(%{page_size: page_size, page_number: page_number}) do
    User |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all(%{page_size: page_size, page_number: page_number, org_id: org_id}, preloads) do
    query =
      from(user in User,
        join: org in Organisation,
        on: user.org_id == ^org_id and org.id == ^org_id and user.is_deleted == false
      )

    paginated_user_data =
      query |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    user_data_with_preloads = paginated_user_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(user_data_with_preloads, paginated_user_data)
  end

  @doc """
  Deletes a User.

  Expects `user` as the argument.
  """
  def delete(user) do
    changeset = User.update_changeset(user, %{is_deleted: true})

    case Repo.update(changeset) do
      {:ok, user} -> {:ok, user |> Repo.preload([:role, :org])}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Update a User.

  Expects `user` and update parameters as the arguments
  """
  def update_user(%User{} = user, params) do
    changeset = User.update_changeset(user, params)

    case Repo.update(changeset) do
      {:ok, user} -> {:ok, user |> Repo.preload([:role, :org])}
      {:error, message} -> {:error, message}
    end

    changeset = User.update_changeset(user, params)

    case Repo.update(changeset) do
      {:ok, user} -> {:ok, user |> Repo.preload([:role, :org])}
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

  @doc """
  Extract out the email of given user
  """
  def extract_email(user_id) when is_integer(user_id) do
    query =
      from(user in User,
        where: user.id == ^user_id,
        select: user
      )

    Repo.one!(query) |> Repo.preload(:org)
  end
end
