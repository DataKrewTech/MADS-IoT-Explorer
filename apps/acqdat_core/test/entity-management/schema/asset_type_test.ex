defmodule AcqdatCore.Schema.AssetTypeTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory

  alias AcqdatCore.Schema.EntityManagement.AssetType

  describe "changeset/2" do
    setup do
      organisation = insert(:organisation)
      [organisation: organisation]
    end

    test "returns a valid changeset", context do
      %{organisation: organisation} = context

      params = %{
        name: "Asset Type 8",
        description: "This is asset type description",
        metadata: [
          %{
            name: "metadata 1",
            type: "Type 1",
            unit: "abc"
          },
          %{
            name: "metadata2",
            type: "Type 2",
            unit: "def"
          },
          %{
            name: "metadata3",
            type: "Type 3",
            unit: "ghi"
          }
        ],
        parameters: [
          %{
            name: "param 1",
            data_type: "Type 2",
            unit: "abc"
          },
          %{
            name: "param 2",
            data_type: "Type 1",
            unit: "def"
          }
        ],
        org_id: organisation.id
      }

      %{valid?: validity} = AssetType.changeset(%AssetType{}, params)
      assert validity
    end

    test "returns invalid if params empty" do
      %{valid?: validity} = changeset = AssetType.changeset(%AssetType{}, %{})
      refute validity

      assert %{
               org_id: ["can't be blank"],
               name: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "returns error if assoc constraint not satisfied", _context do
      params = %{
        name: "Temperature",
        org_id: -1
      }

      changeset = AssetType.changeset(%AssetType{}, params)

      {:error, result_changeset} = Repo.insert(changeset)
      assert %{org: ["does not exist"]} == errors_on(result_changeset)
    end

    test "returns error if unique constraint not satisified", _context do
      params = %{
        name: "Temperature",
        org_id: 1
      }

      changeset = AssetType.changeset(%AssetType{}, params)

      Repo.insert(changeset)

      params = %{
        name: "Temperature",
        org_id: 1
      }

      new_changeset = AssetType.changeset(%AssetType{}, params)
      {:error, result_changeset} = Repo.insert(new_changeset)
      assert %{org: ["does not exist"]} == errors_on(result_changeset)
    end
  end
end
