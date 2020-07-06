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

  describe "get_gateways/1" do
    setup do
      project = insert(:project)
      gateway1 = insert(:gateway, parent_type: "Project", parent_id: project.id)
      gateway2 = insert(:gateway, parent_type: "Project", parent_id: project.id)
      sensor1 = insert(:sensor, gateway_id: gateway1.id)
      sensor2 = insert(:sensor, gateway_id: gateway2.id)

      [
        project: project,
        gateway1: gateway1,
        gateway2: gateway2,
        sensor1: sensor1,
        sensor2: sensor2
      ]
    end

    test "fetch heirarchy with gateways", %{
      project: project,
      gateway1: gateway1,
      gateway2: gateway2,
      sensor1: sensor1,
      sensor2: sensor2
    } do
      gateways = Project.get_gateways(project.id)
      [resulted_gateway1, resulted_gateway2] = gateways
      [child1] = resulted_gateway1.childs
      [child2] = resulted_gateway2.childs
      assert resulted_gateway1.name == gateway1.name
      assert resulted_gateway2.name == gateway2.name
      assert resulted_gateway1.parent.id == project.id
      assert resulted_gateway2.parent.id == project.id
      assert child1.id == sensor1.id
      assert child2.id == sensor2.id
    end
  end
end
