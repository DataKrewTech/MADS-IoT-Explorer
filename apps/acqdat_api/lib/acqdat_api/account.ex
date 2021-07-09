defmodule AcqdatApi.Account do
  @moduledoc """
  Module exposes functions to handle account authentication and authorization.
  """

  alias AcqdatCore.Domain.Account
  alias AcqdatApiWeb.Guardian
  alias AcqdatCore.Model.EntityManagement.Organisation
  alias AcqdatCore.Model.RoleManagement.Requests
  alias AcqdatCore.Model.RoleManagement.User

  @access_time_hours 5
  @refresh_time_weeks 1

  @doc """
  Uses `email` and `password` supplied in params to verify the user.

  Returns an `access_token`, `refresh_token` and `user_id` if the user
  is authenticated.
  If email and password not verified then returns unauthorized access.
  """
  @spec sign_in(map) :: {:ok, map} | {:error, String.t()}
  def sign_in(params) do
    %{email: email, password: password} = params

    res = Account.authenticate(email, password)
    org_ids = User.fetch_user_orgs_by_email(email)

    case {res, org_ids} do
      {_, []} ->
        {:error, "credentials not found"}

      {{:ok, user}, _} ->
        {:ok, access_token, _} =
          guardian_create_token(
            user,
            {@access_time_hours, :hours},
            :access
          )

        {:ok, refresh_token, _} =
          guardian_create_token(
            user,
            {@refresh_time_weeks, :weeks},
            :refresh
          )

        {:ok,
         %{
           email: email,
           credentials_id: user.id,
           access_token: access_token,
           refresh_token: refresh_token,
           orgs: Organisation.get_all_by_ids(org_ids)
         }}

      {{:error, error}, _} ->
        {:error, error}
    end
  end

  @doc """
  Uses `email` and `password` supplied in params to verify the user.

  Returns an `access_token`, `refresh_token` and `user_id` if the user
  is authenticated.
  If email and password not verified then returns unauthorized access.
  """
  @spec org_sign_in(map, Integer.t()) :: {:ok, map} | {:error, String.t()}
  def org_sign_in(%{org_id: org_id}, credential_id) do
    verify_account(Account.authenticate_identity(org_id, credential_id))
  end

  @doc """
  Validates the `access` token for authorization.

  If the token is valid return it as such otherwise, generates an acces token
  from the supplied `refresh_token`. In case the refresh token is also expired
  an error tuple is returned.
  """
  @spec validate_token(map) :: {:ok, map} | {:error, any}
  def validate_token(%{refresh_token: refresh_token, access_token: access_token}) do
    access_token
    |> Guardian.decode_and_verify(%{"typ" => "access"})
    |> assess_token(access_token, refresh_token)
  end

  @doc """
  Signs out a user by revoking the tokens(`access`, `refresh`).

  #TODO: Use GuardianDB to revoke tokens and track them. At present tokens
        are not being tracked.
  """
  def sign_out(params) do
    %{refresh_token: refresh, access_token: access} = params

    with {:ok, _} <- Guardian.revoke(refresh),
         {:ok, _} <- Guardian.revoke(access) do
      {:ok, "Signed Out"}
    else
      {:error, _} = error ->
        error
    end
  end

  def register(%{org_url: org_url} = params) do
    orgs = Organisation.fetch_by_url(org_url)

    if orgs == [] do
      params = params |> Map.from_struct()
      Requests.create(params)
    else
      {:error, %{error: "This Organisation Url has been already taken"}}
    end
  end

  def validate_credentials(params, %{password: password, org_id: org_id}) do
    Account.authenticate(params.user_credentials.email, password, org_id)
  end

  ############## private functions #####################

  defp verify_account({:ok, user}) do
    {:ok, access_token, _} =
      guardian_create_token(
        user,
        {@access_time_hours, :hours},
        :access
      )

    {:ok, refresh_token, _} =
      guardian_create_token(
        user,
        {@refresh_time_weeks, :weeks},
        :refresh
      )

    {:ok, %{access_token: access_token, user_id: user.id, refresh_token: refresh_token}}
  end

  defp verify_account({:error, _}) do
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

  defp assess_token({:ok, _}, access_token, _) do
    resource = get_resource(access_token)

    {:ok, %{access_token: access_token, user_id: resource}}
  end

  defp assess_token({:error, %ArgumentError{}} = result, _, _),
    do: result

  defp assess_token({:error, _}, _, refresh_token) do
    {:ok, _, {new_token, _}} =
      Guardian.exchange(refresh_token, "refresh", "access", ttl: {@access_time_hours, :hours})

    resource = get_resource(new_token)
    {:ok, %{access_token: new_token, user_id: resource}}
  end

  defp get_resource(token) do
    {:ok, resource, _} = Guardian.resource_from_token(token)
    resource
  end
end
