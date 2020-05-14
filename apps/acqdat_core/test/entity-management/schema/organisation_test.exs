defmodule AcqdatCore.Schema.EntityManagement.OrganisationTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  alias AcqdatCore.Schema.EntityManagement.Organisation

  describe "changeset/2" do
    test "adding valid params returns valid changeset" do
      params = %{
        name: "DataCrew",
        uuid: UUID.uuid1(:hex)
      }

      %{valid?: validity} = Organisation.changeset(%Organisation{}, params)
      assert validity
    end

    test "returns invalid changeset if name is not present" do
      params = %{
        uuid: UUID.uuid1(:hex)
      }

      %{valid?: validity} = changeset = Organisation.changeset(%Organisation{}, params)
      refute validity
      assert %{name: ["can't be blank"]} == errors_on(changeset)
    end

    test "returns invalid changeset if name is not unique" do
      org = insert(:organisation)

      params = %{
        name: org.name,
        uuid: UUID.uuid1(:hex)
      }

      changeset = Organisation.changeset(%Organisation{}, params)

      assert {:error, changeset} = Repo.insert(changeset)
      assert %{name: ["has already been taken"]} == errors_on(changeset)
    end
  end
end
