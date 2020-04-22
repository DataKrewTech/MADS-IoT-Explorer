defmodule AcqdatCore.Domain.AccountTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.User
  alias AcqdatCore.Domain.Account

  describe "authenticate/2" do
    setup do
      org = insert(:organisation)
      role = insert(:role)

      params =
        build(:user)
        |> Map.put(:password, "stark1234")
        |> Map.put(:password_confirmation, "stark1234")
        |> Map.put(:org_id, org.id)
        |> Map.put(:role_id, role.id)
        |> Map.from_struct()

      {:ok, user} = User.create(params)
      [user: user, user_params: params]
    end

    test "authenticates a user", %{user: user, user_params: params} do
      assert {:ok, rt_user} = Account.authenticate(user.email, params.password)
      assert user.first_name == rt_user.first_name
      assert user.email == rt_user.email
    end

    test "fails if email wrong", %{user_params: params} do
      assert {:error, message} =
               Account.authenticate(
                 "xyz@gmail.com",
                 params.password
               )

      assert message == :not_found
    end

    test "fails if password wrong", %{user: user} do
      assert {:error, message} =
               Account.authenticate(
                 user.email,
                 "abc123"
               )

      assert message == :not_found
    end
  end
end
