defmodule AcqdatCore.Domain.Account do
  @moduledoc """
  Exposes domain functions for authentication.
  """
  alias AcqdatCore.Model.RoleManagement.User
  alias Acqdat.Schema.RoleManagement.User, as: UserSchema
  alias Comeonin.Argon2

  @doc """
  Authenticates a user against the supplied params, email and password.

  Returns user struct if found else returns not_found.
  """
  @spec authenticate(String.t(), String.t()) ::
          {:ok, UserSchema.t()}
          | {:error, :not_found}
  def authenticate(email, password) do
    email
    |> User.get()
    |> verify_email(password)
  end

  ###################### private functions ###########################

  defp verify_email(nil, _) do
    # To make user enumeration difficult.
    Argon2.dummy_checkpw()
    {:error, :not_found}
  end

  defp verify_email(user, password) do
    verify_password(user, Argon2.checkpw(password, user.password_hash))
  end

  defp verify_password(user, true = _password_matches), do: {:ok, user}
  defp verify_password(_user, _), do: {:error, :not_found}
end
