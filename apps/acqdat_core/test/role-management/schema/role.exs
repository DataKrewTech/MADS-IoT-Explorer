defmodule AcqdatCore.Schema.RoleManagement.RoleTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory

  alias AcqdatCore.Schema.RoleManagement.Role

  describe "changeset/2" do
    test "returns a valid changeset" do
      params = %{
        name: "admin",
        description: "Admin of the organisation"
      }

      %{valid?: validity} = Role.changeset(%Role{}, params)
      assert validity
    end

    test "returns invalid if params empty" do
      %{valid?: validity} = changeset = Role.changeset(%Role{}, %{})
      refute validity

      assert %{
               name: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "returns error if wrong name is given" do
      params = %{
        name: "Bintan Factory"
      }

      changeset = Role.changeset(%Role{}, params)

      assert %{
               name: ["is invalid"]
             } = errors_on(changeset)
    end
  end
end
