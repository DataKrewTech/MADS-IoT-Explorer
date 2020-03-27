defmodule AcqdatCore.Schema.AssetTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory

  alias AcqdatCore.Schema.Asset

  describe "changeset/2" do
    setup do
      organisation = insert(:organisation)
      [organisation: organisation]
    end

    test "returns a valid changeset", context do
      %{organisation: organisation} = context

      params = %{
        name: "Bintan Factory",
        org_id: organisation.id,
        parent_id: organisation.id
      }

      %{valid?: validity} = Asset.changeset(%Asset{}, params)
      assert validity
    end

    test "returns invalid if params empty" do
      %{valid?: validity} = changeset = Asset.changeset(%Asset{}, %{})
      refute validity

      assert %{
               org_id: ["can't be blank"],
               parent_id: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "returns error if assoc constraint not satisfied", _context do
      params = %{
        name: "Bintan Factory",
        org_id: -1,
        parent_id: -1
      }

      changeset = Asset.changeset(%Asset{}, params)

      {:error, result_changeset} = Repo.insert(changeset)
      assert %{org: ["does not exist"]} == errors_on(result_changeset)
    end
  end
end
