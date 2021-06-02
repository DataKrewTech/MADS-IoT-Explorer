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

  @doc """
  Returns a user by the supplied id.
  """
  def get(id) when is_integer(id) do
    case Repo.get(UserCredentials, id) do
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
    # query = from(
    #   cred in UserCredentials,
    #   join: users in User,
    #   on:
    #     cred.id == users.user_credentials_id and cred.email == ^email and
    #     users.org_id == ^org_id
    # )

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

  @doc """
  Returns a user by the supplied email.
  """
  def get(email) when is_binary(email) do
    Repo.get_by(UserCredentials, email: email)
  end
end
