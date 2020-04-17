defmodule AcqdatCore.Model.UserTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  alias AcqdatCore.Model.User

  describe "set_asset/2" do
    test "associates assets with user" do
      user = insert(:user)
      asset = insert(:asset)

      asset_params = [%{"id" => asset.id, "name" => asset.name}]

      {:ok, result} = User.set_asset(user, asset_params)
      assert not is_nil(result)
    end
  end

  describe "set_app/2" do
    test "associates app with user" do
      user = insert(:user)
      app = insert(:app)

      asset_params = [%{"id" => app.id, "name" => app.name}]

      {:ok, result} = User.set_apps(user, asset_params)
      assert not is_nil(result)
    end
  end
end
