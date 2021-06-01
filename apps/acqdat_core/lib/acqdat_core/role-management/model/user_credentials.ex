defmodule AcqdatCore.Model.RoleManagement.UserCredentials do
  @moduledoc """
  User credentials
  """

  alias AcqdatCore.Repo
  alias Ecto.Multi
  alias AcqdatCore.Schema.RoleManagement.UserCredentials
  import Ecto.Query

  @doc """
  Creates a UserCredentials with the supplied params.

  Expects following keys.
  - `first_name`
  - `last_name`
  - `email`
  - `phone number`
  - `password hash`
  """

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
end
