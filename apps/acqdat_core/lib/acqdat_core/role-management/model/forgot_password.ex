defmodule AcqdatCore.Model.RoleManagement.ForgotPassword do
  alias AcqdatCore.Schema.RoleManagement.ForgotPassword
  alias AcqdatCore.Model.RoleManagement.UserCredentials
  alias AcqdatCore.Repo
  import Ecto.Query

  def create(params) do
    %ForgotPassword{}
    |> ForgotPassword.changeset(params)
    |> Repo.insert()
  end

  def verify_token(token) do
    query =
      from(details in ForgotPassword,
        where: details.token == ^token
      )

    case List.first(Repo.all(query)) do
      nil ->
        {:error, "Token is invalid"}

      details ->
        UserCredentials.get(details.user_id)
    end
  end

  def delete(user_id) do
    query =
      from(details in ForgotPassword,
        where: details.user_id == ^user_id
      )

    Repo.delete(List.first(Repo.all(query)))
  end
end
