defmodule AcqdatCore.Schema.EntityManagement.AssetCategoryTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Schema.EntityManagement.AssetCategory

  describe "changeset/2" do
    test "returns a valid changeset" do
      organisation = insert(:organisation)

      params =
        :asset_category
        |> build()
        |> Map.from_struct()
        |> Map.put(:organisation_id, organisation.id)

      %{valid?: validity} = AssetCategory.changeset(%AssetCategory{}, params)
      assert validity
    end
  end

  test "fails for missing params" do
    params = %{}
    %{valid?: validity} = changeset = AssetCategory.changeset(%AssetCategory{}, params)
    refute validity

    assert %{
             name: ["can't be blank"],
             organisation_id: ["can't be blank"]
           } == errors_on(changeset)
  end

  test "fails if two asset categories with same name come under org" do
    organisation = insert(:organisation)
    asset_1 = insert(:asset_category, organisation: organisation)

    params =
      :asset_category
      |> build(name: asset_1.name)
      |> Map.from_struct()
      |> Map.put(:organisation_id, organisation.id)

    changeset = AssetCategory.changeset(%AssetCategory{}, params)
    {result, changeset} = Repo.insert(changeset)

    assert result == :error
    assert %{name: ["unique name per organisation"]} == errors_on(changeset)
  end

  test "passes if two asset categories with same name come under different org" do
    organisation_1 = insert(:organisation)
    asset_1 = insert(:asset_category, organisation: organisation_1)
    organisation_2 = insert(:organisation)

    params =
      :asset_category
      |> build(name: asset_1.name)
      |> Map.from_struct()
      |> Map.put(:organisation_id, organisation_2.id)

    changeset = AssetCategory.changeset(%AssetCategory{}, params)
    {result, asset_2} = Repo.insert(changeset)
    assert result == :ok
    assert asset_2.name == asset_1.name
  end
end
