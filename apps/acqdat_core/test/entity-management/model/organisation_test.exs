defmodule AcqdatCore.Model.EntityManagement.OrganisationTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.EntityManagement.Organisation

  describe "get_by_id/1" do
    test "returns a particular organisation" do
      org = insert(:organisation)

      {:ok, result} = Organisation.get_by_id(org.id)
      assert not is_nil(result)
      assert result.id == org.id
    end

    test "returns error not found, if organisation is not present" do
      {:error, result} = Organisation.get_by_id(-1)
      assert result == "organisation not found"
    end
  end

  describe "get/2" do
    setup do
      org = insert(:organisation)
      project = insert(:project)
      asset = insert(:asset)

      {:ok, _root_asset} =
        Asset.add_as_root(%{
          name: "root asset",
          org_id: project.org_id,
          org_name: org.name,
          project_id: project.id,
          asset_type_id: asset.asset_type_id,
          creator_id: asset.creator_id,
          metadata: [],
          mapped_parameters: [],
          owner_id: asset.creator_id,
          properties: []
        })

      [project: project]
    end

    test "returns a project hierarchy tree", context do
      %{project: project} = context

      {:ok, result} = Organisation.get(project.org_id, project.id)
      assert not is_nil(result)
    end

    test "returns error not found, if organisation is not present", context do
      %{project: project} = context

      {:error, result} = Organisation.get(-1, project.id)
      assert result == "organisation not found"
    end
  end
end
