defmodule AcqdatCore.Schema.RoleManagement.UserAppTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory

  alias AcqdatCore.Schema.RoleManagement.UserApp

  describe "changeset/2" do
    setup do
      user = insert(:user)
      app = insert(:app)

      [user: user, app: app]
    end

    test "returns a valid changeset", context do
      %{user: user, app: app} = context

      params = %{
        user_id: user.id,
        app_id: app.id
      }

      %{valid?: validity} = UserApp.changeset(%UserApp{}, params)
      assert validity
    end

    test "returns error changeset on empty params" do
      changeset = UserApp.changeset(%UserApp{}, %{})

      assert %{user_id: ["can't be blank"], app_id: ["can't be blank"]} == errors_on(changeset)
    end

    test "returns error when invalid user_id is inserted", context do
      %{app: app} = context

      assert {:error, changeset} =
               Repo.insert(UserApp.changeset(%UserApp{}, %{user_id: -1, app_id: app.id}))

      assert %{user_id: ["does not exist"]} == errors_on(changeset)
    end

    test "returns error when invalid app_id is inserted", context do
      %{user: user} = context

      assert {:error, changeset} =
               Repo.insert(UserApp.changeset(%UserApp{}, %{user_id: user.id, app_id: -1}))

      assert %{app_id: ["does not exist"]} == errors_on(changeset)
    end

    test "returns error when duplicate combination of user and app is inserted", context do
      %{user: user, app: app} = context
      Repo.insert(UserApp.changeset(%UserApp{}, %{user_id: user.id, app_id: app.id}))

      assert {:error, changeset} =
               Repo.insert(UserApp.changeset(%UserApp{}, %{user_id: user.id, app_id: app.id}))

      assert %{user_id: ["has already been taken"]} == errors_on(changeset)
    end
  end
end
