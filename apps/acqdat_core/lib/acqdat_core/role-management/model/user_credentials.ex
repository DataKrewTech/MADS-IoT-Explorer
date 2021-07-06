defmodule AcqdatCore.Model.RoleManagement.UserCredentials do
  @moduledoc """
  User credentials
  """

  import Ecto.Query
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.RoleManagement.{User, UserCredentials}

  @doc """
  Creates a UserCredentials with the supplied params.

  Expects following keys.
  - `first_name`
  - `last_name`
  - `email`
  - `phone number`
  - `password hash`
  """

  @spec create(map) :: {:ok, UserCredentials.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    changeset = UserCredentials.changeset(%UserCredentials{}, params)
    Repo.insert(changeset)
  end

  def update(credentials, params) do
    changeset = UserCredentials.update_changeset(credentials, params)
    Repo.update(changeset)
  end

  def reset_password(credentials, params) do
    changeset = UserCredentials.reset_password_changeset(credentials, params)
    Repo.update(changeset)
  end

  def update_details(id, params) do
    case Repo.get(UserCredentials, id) |> Repo.preload([:user_setting]) do
      nil ->
        {:error, "user_credentials not found"}

      credentials ->
        changeset = UserCredentials.changeset(credentials, params)
        Repo.update(changeset)
    end
  end

  def find_or_create(%{email: email} = params) do
    case Repo.get_by(UserCredentials, email: email) do
      nil ->
        create(params)

      user_credentials ->
        {:ok, user_credentials}
    end
  end

  @doc """
  Returns a user by the supplied id.
  """
  def get(id) when is_integer(id) do
    case Repo.get(UserCredentials, id) |> Repo.preload([:user_setting]) do
      nil ->
        {:error, "not found"}

      user_details ->
        {:ok, user_details}
    end
  end

  @doc """
  Validates identity and returns user_credentials
  """
  def get_by_email_n_org(email, org_id) do
    query =
      from(
        user in User,
        join: cred in UserCredentials,
        on:
          cred.id == user.user_credentials_id and cred.email == ^email and
            user.org_id == ^org_id
      )

    Repo.one(query) |> Repo.preload([:user_credentials])
  end

  def get_by_cred_n_org(cred_id, org_id) do
    query =
      from(
        user in User,
        join: cred in UserCredentials,
        on:
          cred.id == user.user_credentials_id and cred.id == ^cred_id and
            user.org_id == ^org_id
      )

    Repo.one(query) |> Repo.preload([:user_credentials])
  end

  @doc """
  Returns a user by the supplied email.
  """
  def get(email) when is_binary(email) do
    Repo.get_by(UserCredentials, email: email)
  end
end
