defmodule AcqdatCore.Schema.RoleManagement.UserTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Schema.RoleManagement.User

  describe "changeset/2" do
    test "returns error changeset on empty params" do
      changeset = User.changeset(%User{}, %{})

      assert %{
               email: ["can't be blank"],
               first_name: ["can't be blank"],
               password: ["can't be blank"],
               password_confirmation: ["can't be blank"],
               org_id: ["can't be blank"],
               role_id: ["can't be blank"]
             } == errors_on(changeset)
    end

    test "returns error if password and confirm do not match" do
      org = insert(:organisation)

      params = %{
        first_name: "Tony",
        last_name: "Stark",
        email: "tony@starkindustries.com",
        password: "marvel_connect",
        password_confirmation: "marvel",
        org_id: org.id,
        role_id: 3,
        is_invited: false
      }

      changeset = User.changeset(%User{}, params)

      assert %{
               password_confirmation: ["does not match confirmation"]
             } == errors_on(changeset)
    end

    test "returns error if email regex not matched" do
      org = insert(:organisation)

      params = %{
        first_name: "Tony",
        last_name: "Stark",
        email: "tonystarkindustries.com",
        password: "marvel_connect",
        password_confirmation: "marvel_connect",
        org_id: org.id,
        role_id: 3,
        is_invited: false
      }

      changeset = User.changeset(%User{}, params)

      assert %{
               email: ["has invalid format"]
             } == errors_on(changeset)
    end
  end

  describe "assets/2" do
    setup do
      user = insert(:user)

      [user: user]
    end

    test "updates assets of the user", context do
      project = insert(:project)
      asset = insert(:asset)
      %{user: user} = context

      %{valid?: validity} = User.associate_asset_changeset(user, [asset])
      assert validity
    end
  end

  describe "apps/2" do
    setup do
      user = insert(:user)

      [user: user]
    end

    test "updates apps of the user", context do
      app = insert(:app)
      %{user: user} = context

      %{valid?: validity} = User.associate_app_changeset(user, [app])
      assert validity
    end
  end
end
