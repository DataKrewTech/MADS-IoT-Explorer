defmodule AcqdatCore.StreamLogic.Model.StreamLogicTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.StreamLogic.Model, as: StreamLogic
  alias AcqdatCore.StreamLogic.ConsumerSupervisor

  @params %{
    name: "Workflow1",
    digraph: %{edge_list: [], vertices: []},
    enabled: true,
    metadata: %{}
  }

  describe "create/1" do
    setup do
      project = insert(:project)
      [project: project]
    end

    test "create and register a workflow", %{project: project} do
      digraph = create_digraph()
      params = @params
        |> Map.put(:digraph, digraph)
        |> Map.put(:org_id, project.org.id)
        |> Map.put(:project_id, project.id)
      assert {:ok, workflow} = StreamLogic.create(params)
      result = Supervisor.which_children(ConsumerSupervisor)
      require IEx;IEx.pry
    end

    test "fails if name already exists", %{project: project} do
      workflow = insert(:workflow, project: project, org: project.org)
      digraph = create_digraph()
      params = @params
        |> Map.put(:digraph, digraph)
        |> Map.put(:org_id, project.org.id)
        |> Map.put(:project_id, project.id)
        |> Map.put(:name, workflow.name)
      assert {:error, changeset} = StreamLogic.create(params)
      assert errors_on(changeset) == %{name: ["workflow with this name exists"]}
    end

  end

  describe "update/2 " do
    setup do
      project = insert(:project)
      workflow = insert(:workflow, project: project, org: project.org)
      [project: project, workflow: workflow]
    end

    test "udpate enabled status of the graph", context do
      %{workflow: workflow} = context
      params = %{enabled: false}
      assert {:ok, new_workflow} = StreamLogic.update(workflow, params)
      assert workflow.id == new_workflow.id
      assert new_workflow.enabled == false
    end

    test "updates a workflow graph", context do
      %{workflow: workflow} = context
      digraph = create_digraph()
      params = %{name: "Streamify", digraph: digraph}
      assert {:ok, new_workflow} = StreamLogic.update(workflow, params)
      assert workflow.id == new_workflow.id
      refute workflow.name == new_workflow.name
    end

  end

  describe "get/1 "do
    setup do
      project = insert(:project)
      [project: project]
    end

    test "returns ok tuple if found by id", %{project: project} do
      workflow = insert(:workflow, project: project, org: project.org)
      assert {:ok, _workflow} = StreamLogic.get(workflow.id)
    end

    test "returns ok tuple if found by params", %{project: project} do
      workflow = insert(:workflow, project: project, org: project.org)
      assert {:ok, _workflow} = StreamLogic.get(%{name: workflow.name})
    end

    test "returns error tuple if not found" do
      assert {:error, message} = StreamLogic.get(-1)
      assert message == "not found"
    end
  end

  describe "get_all/0 " do
    setup do
      project = insert(:project)
      [project: project]
    end

    test "returns paginated response", %{project: project} do
      entries = 5
      insert_list(entries, :workflow, project: project, org: project.org)
      params = %{
        page_size: 2,
        page_number: 1,
        org_id: project.org.id,
        project_id: project.id
      }
      result = StreamLogic.get_all(params)
      assert result.page_size == params.page_size
      assert result.page_number == params.page_number
      assert result.total_entries == entries
    end

    test "returns empty list if no entries", %{project: project} do
      params = %{
        page_size: 2,
        page_number: 1,
        org_id: project.org.id,
        project_id: project.id
      }
      result = StreamLogic.get_all(params)
      assert result.entries == []
      assert result.total_entries == 0
    end

    test "returns empty for stale project" do
      params = %{
        page_size: 2,
        page_number: 1,
        org_id: -1,
        project_id: -1
      }
      result = StreamLogic.get_all(params)
      assert result.entries == []
      assert result.total_entries == 0
    end
  end

  describe "delete/1 " do
    setup do
      project = insert(:project)
      workflow = insert(:workflow, project: project, org: project.org)
      [project: project, workflow: workflow]
    end

    test "deletes a workflow", context do
      %{workflow: workflow} = context
      assert {:ok, _workflow} = StreamLogic.delete(workflow)
      assert {:error, message} = StreamLogic.get(workflow.id)
      assert message == "not found"
    end

    test "returns error tuple if not found", context do
      %{workflow: workflow} = context
      StreamLogic.delete(workflow)

      assert {:error, message} = StreamLogic.delete(workflow)
      assert message == "not found"
    end
  end
end
