defmodule AcqdatCore.Schema.RoleManagement.UserCredentialsTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  alias AcqdatCore.Schema.RoleManagement.UserCredentials
  alias AcqdatCore.Repo

  describe "changeset/2" do
    test "returns error changeset on empty params" do
      changeset = UserCredentials.changeset(%UserCredentials{}, %{})

      assert %{
               email: ["can't be blank"],
               first_name: ["can't be blank"]
             } == errors_on(changeset)
    end

    test "returns error if password and confirm do not match" do
      params = %{
        first_name: "Tony",
        last_name: "Stark",
        email: "tony@starkindustries.com",
        password: "marvel_connect",
        password_confirmation: "marvel"
      }

      changeset = UserCredentials.changeset(%UserCredentials{}, params)

      assert %{
               password_confirmation: ["does not match confirmation"]
             } == errors_on(changeset)
    end

    test "returns error if password length is less than 8" do
      params = %{
        first_name: "Tony",
        last_name: "Stark",
        email: "tony@starkindustries.com",
        password: "marvel",
        password_confirmation: "marvel"
      }

      changeset = UserCredentials.changeset(%UserCredentials{}, params)

      assert %{
               password: ["should be at least 8 character(s)"]
             } == errors_on(changeset)
    end

    test "returns error if email regex not matched" do
      params = %{
        first_name: "Tony",
        last_name: "Stark",
        email: "tonystarkindustries.com",
        password: "marvel_connect",
        password_confirmation: "marvel_connect"
      }

      changeset = UserCredentials.changeset(%UserCredentials{}, params)

      assert %{
               email: ["has invalid format"]
             } == errors_on(changeset)
    end

    test "returns user with same email already exists" do
      params = %{
        first_name: "Tony",
        last_name: "Stark",
        email: "test@test.com",
        password: "marvel_connect",
        password_confirmation: "marvel_connect"
      }

      changeset = UserCredentials.changeset(%UserCredentials{}, params)

      Repo.insert(changeset)

      {:error, result} = Repo.insert(changeset)

      assert %{
               email: ["has already been taken"]
             } == errors_on(result)
    end

    test "successfully saves user credentials with proper params" do
      params = %{
        first_name: "Tony",
        last_name: "Stark",
        email: "test@test.com",
        password: "marvel_connect",
        password_confirmation: "marvel_connect"
      }

      changeset = UserCredentials.changeset(%UserCredentials{}, params)

      %{valid?: validity} = UserCredentials.changeset(%UserCredentials{}, params)
      assert validity

      {:ok, _} = Repo.insert(changeset)
    end
  end
end
