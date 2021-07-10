defmodule AcqdatCore.Domain.AccountTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.RoleManagement.User
  alias AcqdatCore.Domain.Account
  alias AcqdatCore.Repo

  describe "authenticate/2" do
    setup do
      org = insert(:organisation)
      role = insert(:role)
      user_credentials = insert(:user_credentials)

      params =
        build(:user, org_id: org.id)
        |> Map.put(:password, "stark1234")
        |> Map.put(:password_confirmation, "stark1234")
        |> Map.put(:org_id, org.id)
        |> Map.put(:role_id, role.id)
        |> Map.put(:user_credentials_id, user_credentials.id)
        |> Map.from_struct()

      {:ok, user} = User.create(params)
      user = Repo.preload(user, [:user_credentials])
      [user: user, user_params: params]
    end

    test "authenticates a user", %{user: user, user_params: params} do
      assert {:ok, rt_user} = Account.authenticate(user.user_credentials.email, params.password)
      assert user.user_credentials.first_name == rt_user.first_name
      assert user.user_credentials.email == rt_user.email
    end

    test "fails if email wrong", %{user_params: params} do
      assert {:error, message} =
               Account.authenticate(
                 "xyz@gmail.com",
                 params.password
               )

      assert message == "credentials not found"
    end

    test "fails if password wrong", %{user: user} do
      assert {:error, message} =
               Account.authenticate(
                 user.user_credentials.email,
                 "abc123"
               )

      assert message == :not_found
    end
  end
end
