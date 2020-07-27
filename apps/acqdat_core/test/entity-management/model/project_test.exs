defmodule AcqdatCore.Model.EntityManagement.ProjectTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory

  alias AcqdatCore.Model.EntityManagement.Project

  describe "get_by_id/1" do
    test "returns a particular project" do
      proj = insert(:project)

      {:ok, result} = Project.get_by_id(proj.id)
      assert not is_nil(result)
      assert result.id == proj.id
    end

    test "returns error not found, if project is not present" do
      {:error, result} = Project.get_by_id(-1)
      assert result == "not found"
    end
  end

  describe "update_version/2" do
    setup do
      project = insert(:project)

      [project: project]
    end

    test "updates the project's name", context do
      %{project: project} = context

      assert {:ok, result} = Project.update_version(project)
      assert result.version == Decimal.add(project.version, "0.1")
    end
  end

  describe "hierarchy_data/2" do
    setup do
      project = insert(:project)

      [project: project]
    end

    test "fetch project tree hierarchy_data", context do
      %{project: project} = context

      result = Project.hierarchy_data(project.org_id, project.id)
      assert length(result) != 0
    end
  end

  describe "delete/1" do
    test "deletes a particular project" do
      project = insert(:project)

      {:ok, result} = Project.delete(project)

      assert not is_nil(result)
      assert result.id == project.id
    end

    test "will raise error if project have associated asset_types" do
      asset_type = insert(:asset_type)

      {:ok, project} = Project.get_by_id(asset_type.project_id)
      {:error, changeset} = Project.delete(project)

      assert %{asset_types: ["asset_types are attached to this project"]} == errors_on(changeset)
    end

    test "will raise error if project have associated sensor_types" do
      sensor_type = insert(:sensor_type)

      {:ok, project} = Project.get_by_id(sensor_type.project_id)
      {:error, changeset} = Project.delete(project)

      assert %{sensor_types: ["sensor_types are attached to this project"]} ==
               errors_on(changeset)
    end
  end
end
