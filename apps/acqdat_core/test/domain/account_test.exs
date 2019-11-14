defmodule AcqdatCore.Domain.AccountTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  alias AcqdatCore.Model.User
  alias AcqdatCore.Domain.Account

  describe "authenticate/2" do
    setup do
      params = %{
        first_name: "Tony",
        last_name: "Stark",
        email: "tony@starkindustries.com",
        password: "stark1234",
        password_confirmation: "stark1234"
      }
      {:ok, user} = User.create(params)
      [user: user, user_params: params]
    end

    test "authenticates a user", %{user: user, user_params: params} do
      assert {:ok, rt_user} = Account.authenticate(user.email, params.password)
      assert user.first_name == rt_user.first_name
      assert user.email == rt_user.email
    end

    test "fails if email wrong", %{user_params: params} do
      assert {:error, message} = Account.authenticate("xyz@gmail.com",
        params.password)
      assert message == :not_found
    end

    test "fails if password wrong", %{user: user} do
      assert {:error, message} = Account.authenticate(user.email,
        "abc123")
      assert message == :not_found
    end
  end
end
