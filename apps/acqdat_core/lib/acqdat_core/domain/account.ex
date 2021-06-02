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
  def authenticate(email, password, org_id) do
    email
    |> UserCredentials.get_by_email_n_org(org_id)
    |> verify_email(password)
  end

  ###################### private functions ###########################

  defp verify_email(nil, _) do
    # To make user enumeration difficult.
    Argon2.dummy_checkpw()
    {:error, :not_found}
  end

  defp verify_email(user, password) do
    case user.is_deleted do
      false ->
        verify_password(user, Argon2.checkpw(password, user.user_credentials.password_hash))

      true ->
        Argon2.dummy_checkpw()
        {:error, :not_found}
    end
  end

  defp verify_password(user, true = _password_matches), do: {:ok, user}
  defp verify_password(_user, _), do: {:error, :not_found}
end
