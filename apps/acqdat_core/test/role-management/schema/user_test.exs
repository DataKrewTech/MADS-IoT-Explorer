defmodule AcqdatCore.Schema.RoleManagement.UserTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Schema.RoleManagement.User

  describe "changeset/2" do
    test "returns error changeset on empty params" do
      changeset = User.changeset(%User{}, %{})

      assert %{
               org_id: ["can't be blank"],
               role_id: ["can't be blank"],
               user_credentials_id: ["can't be blank"]
             } == errors_on(changeset)
    end
  end

  describe "assets/2" do
    setup do
      user = insert(:user)

      [user: user]
    end

    test "updates assets of the user", context do
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
