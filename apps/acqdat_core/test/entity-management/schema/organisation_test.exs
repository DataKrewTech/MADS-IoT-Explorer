defmodule AcqdatCore.Schema.EntityManagement.OrganisationTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Repo

  alias AcqdatCore.Schema.EntityManagement.Organisation

  describe "changeset/2" do
    test "adding valid params returns valid changeset" do
      params = %{
        name: "DataCrew",
        uuid: UUID.uuid1(:hex),
        url: "org_url"
      }

      %{valid?: validity} = Organisation.changeset(%Organisation{}, params)
      assert validity
    end

    test "returns invalid changeset if name is not present" do
      params = %{
        uuid: UUID.uuid1(:hex),
        url: "org_url"
      }

      %{valid?: validity} = changeset = Organisation.changeset(%Organisation{}, params)
      refute validity
      assert %{name: ["can't be blank"]} == errors_on(changeset)
    end

    test "returns invalid changeset if url is not unique" do
      org = insert(:organisation)

      params = %{
        name: org.name,
        uuid: UUID.uuid1(:hex),
        url: "org_url"
      }

      changeset = Organisation.changeset(%Organisation{}, params)
      Repo.insert(changeset)

      params = %{
        name: org.name,
        uuid: UUID.uuid1(:hex),
        url: "org_url"
      }

      changeset = Organisation.changeset(%Organisation{}, params)
      assert {:error, changeset} = Repo.insert(changeset)
      assert %{url: ["has already been taken"]} == errors_on(changeset)
    end
  end
end
