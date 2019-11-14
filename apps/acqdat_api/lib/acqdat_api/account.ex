defmodule AcqdatApi.Account do
  @moduledoc """
  Module exposes functions to handle account authentication and authorization.
  """

  alias AcqdatCore.Domain.Account
  alias AcqdatApiWeb.Guardian

  @access_time_hours 5
  @refresh_time_weeks 4

  @doc """
  Uses `email` and `password` supplied in params to verify the user.

  Returns an `access_token`, `refresh_token` and `user_id` if the user
  is authenticated.
  If email and password not verified then returns unauthorized access.
  """
  @spec sign_in(map) :: {:ok, map} | {:error, String.t()}
  def sign_in(params) do
    %{email: email, password: password} = params

    verify_account(Account.authenticate(email, password))
  end

  @doc """
  Refreshes `access` token for authorization.

  Takes as input `refresh_token`, and generates a new
  access token.

  > To be used when the `access_token` is expired.
  """
  @spec refresh_token(map) :: {:ok, String.t()} | {:error, String.t()}
  def refresh_token(refresh_token) do
    case Guardian.exchange(refresh_token, "refresh",
        "access", ttl: @access_time_hours)
      do
        {:ok, token, _claims} ->
          {:ok, token}
        {:error, _reason} = error ->
          error
    end
  end

  ############## private functions #####################

  defp verify_account({:ok, user}) do
    {:ok, access_token, _claims} = guardian_create_token(
      user, {@access_time_hours, :hours}, :access
    )

    {:ok, refresh_token, _claims} = guardian_create_token(
      user, {@refresh_time_weeks, :weeks}, :refresh
    )

    {:ok, %{
        access_token: access_token,
        user_id: user.id,
        refresh_token: refresh_token}
    }
  end

  defp verify_account({:error, _message}) do
    {:error, "unauthenticated"}
  end

  defp guardian_create_token(resource, time, token_type) do
    Guardian.encode_and_sign(
      resource,
      %{},
      token_type: token_type,
      ttl: time
    )
  end
end
