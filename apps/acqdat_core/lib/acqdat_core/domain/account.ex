defmodule AcqdatCore.Domain.Account do
  @moduledoc """
  Exposes domain functions for authentication.
  """
  alias AcqdatCore.Model.RoleManagement.UserCredentials
  alias Acqdat.Schema.RoleManagement.User, as: UserSchema
  alias Comeonin.Argon2

  @doc """
  Authenticates a user against the supplied params, email and password.

  Returns user struct if found else returns not_found.
  """
  @spec authenticate(String.t(), String.t(), Integer.t()) ::
          {:ok, UserSchema.t()}
          | {:error, :not_found}
  def authenticate(email, org_id, _credentials) do
    email
    |> UserCredentials.get_by_email_n_org(org_id)
    |> verify_identity()
  end

  @doc """
  Authenticates an identity against the supplied params, org_id and credential_id.

  Returns user struct if found else returns not_found.
  """
  @spec authenticate(Integer.t(), Integer.t()) ::
          {:ok, UserSchema.t()}
          | {:error, :not_found}
  def authenticate_identity(org_id, credential_id) do
    credential_id
    |> UserCredentials.get_by_cred_n_org(org_id)
    |> verify_identity()
  end

  @doc """
  Authenticates a user against the supplied params, email and password.

  Returns user struct if found else returns not_found.
  """
  @spec authenticate(String.t(), String.t()) ::
          {:ok, UserSchema.t()}
          | {:error, :not_found}
  def authenticate(email, password) do
    email
    |> UserCredentials.get()
    |> verify_user_credentials(password)
  end

  ###################### private functions ###########################

  defp verify_user_credentials(nil, _) do
    # To make user enumeration difficult.
    Argon2.dummy_checkpw()
    {:error, "credentials not found"}
  end

  defp verify_user_credentials(user_credentials, password) do
    verify_password(user_credentials, Argon2.checkpw(password, user_credentials.password_hash))
  end

  defp verify_identity(nil) do
    # To make user enumeration difficult.
    Argon2.dummy_checkpw()
    {:error, "Identity not found"}
  end

  defp verify_identity(user) do
    case user.is_deleted do
      false ->
        {:ok, user}

      true ->
        Argon2.dummy_checkpw()
        {:error, :not_found}
    end
  end

  defp verify_password(user, true = _), do: {:ok, user}
  defp verify_password(_, _), do: {:error, :not_found}
end
