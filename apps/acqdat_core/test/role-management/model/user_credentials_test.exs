defmodule AcqdatCore.Model.RoleManagement.UserCredentialsTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.RoleManagement.UserCredentials

  describe "create/1" do
    test "creates a user_credentials with supplied params" do
      params = %{
        first_name: "Tony",
        last_name: "Stark",
        email: "test@test.com",
        password: "marvel_connect",
        password_confirmation: "marvel_connect"
      }

      assert {:ok, _} = UserCredentials.create(params)
    end

    test "fails if params is not present" do
      assert {:error, changeset} = UserCredentials.create(%{})

      assert %{email: ["can't be blank"], first_name: ["can't be blank"]} == errors_on(changeset)
    end
  end

  describe "update/2" do
    setup do
      user_credentials = insert(:user_credentials)
      [user_credentials: user_credentials]
    end

    test "updates user_credentials", context do
      %{user_credentials: user_credentials} = context

      params = %{
        first_name: "updated first_name"
      }

      assert user_credentials.first_name != "updated first_name"
      assert {:ok, user_credentials} = UserCredentials.update(user_credentials, params)
      assert user_credentials.first_name == "updated first_name"
    end
  end

  describe "get/1" do
    test "returns a particular user_credentials record" do
      user_credentials = insert(:user_credentials)

      {:ok, result} = UserCredentials.get(user_credentials.id)
      assert not is_nil(result)
      assert result.id == user_credentials.id
    end

    test "returns error if record not found" do
      {:error, result} = UserCredentials.get(-1)
      assert result == "not found"
    end
  end

  describe "get_by_email/1" do
    test "returns a particular user_credentials record by email" do
      user_credentials = insert(:user_credentials)

      result = UserCredentials.get(user_credentials.email)
      assert not is_nil(result)
      assert result.id == user_credentials.id
    end

    test "returns error if record not found" do
      result = UserCredentials.get("")
      assert is_nil(result)
    end
  end

  describe "find_or_create/1" do
    test "returns a particular user_credentials if there is already existing user_credentials with the email" do
      user_credentials = insert(:user_credentials)

      {:ok, result} = UserCredentials.find_or_create(%{email: user_credentials.email})
      assert not is_nil(result)
      assert result.id == user_credentials.id
    end

    test "creates user_credentials if it not not exists with the provided email" do
      params = %{
        first_name: "Tony",
        last_name: "Stark",
        email: "test1@test1.com",
        password: "marvel_connect",
        password_confirmation: "marvel_connect"
      }

      assert {:ok, result} = UserCredentials.find_or_create(params)
      assert not is_nil(result)
      assert result.email == "test1@test1.com"
    end
  end
end
