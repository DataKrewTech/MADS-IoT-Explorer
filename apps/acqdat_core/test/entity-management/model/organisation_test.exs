defmodule AcqdatCore.Model.EntityManagement.OrganisationTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory

  alias AcqdatCore.Model.EntityManagement.Organisation

  describe "get_by_id/1" do
    test "returns a particular organisation" do
      org = insert(:organisation)

      {:ok, result} = Organisation.get(org.id)
      assert not is_nil(result)
      assert result.id == org.id
    end

    test "returns error not found, if organisation is not present" do
      {:error, result} = Organisation.get(-1)
      assert result == "not found"
    end
  end
end
