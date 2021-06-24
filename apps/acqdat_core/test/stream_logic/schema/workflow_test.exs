defmodule AcqdatCore.StreamLogic.Schema.WorkflowTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.StreamLogic.Schema.Workflow
  alias AcqdatCore.StreamLogic.Schema.WorkflowGraph

  @params %{
    name: "Workflow1",
    digraph: %{edge_list: [], vertices: []},
    enabled: true,
    metadata: %{}
  }

  describe "changeset/2 " do
    setup do
      project = insert(:project)
      [project: project]
    end
    test "returns a valid changeset", %{project: project} do
      params = @params
        |> Map.put(:project_id, project.id)
        |> Map.put(:org_id, project.org_id)

      %{valid?: validity} = Workflow.changeset(%Workflow{}, params)
      assert validity
    end

    test "returns invalid if params missing" do
      %{valid?: validity} = changeset = Workflow.changeset(%Workflow{}, %{})
      refute validity
      assert %{
        name: ["can't be blank"],
        org_id: ["can't be blank"],
        project_id: ["can't be blank"]
      } == errors_on(changeset)
    end

    test "return invalid if project does not exist", %{project: project} do
      params = @params
        |> Map.put(:project_id, -1)
        |> Map.put(:org_id, project.org_id)
      changeset = Workflow.changeset(%Workflow{}, params)

      assert {:error, changeset} = Repo.insert(changeset)
      assert errors_on(changeset) == %{project: ["does not exist"]}
    end

    test "returns invalid if name not unique", %{project: project} do
      workflow = insert(:workflow, %{project: project, org: project.org})

      params = @params
        |> Map.put(:project_id, project.id)
        |> Map.put(:org_id, project.org_id)
        |> Map.put(:name, workflow.name)

      changeset = Workflow.changeset(%Workflow{}, params)
      assert {:error, changeset} = Repo.insert(changeset)
      assert errors_on(changeset) == %{name: ["workflow with this name exists"]}
    end

    test "test with graph nodes", %{project: project} do
      digraph = create_digraph()
      params = @params
        |> Map.put(:project_id, project.id)
        |> Map.put(:org_id, project.org_id)
        |> Map.put(:digraph, digraph)

      %{valid?: validity} = changeset = Workflow.changeset(%Workflow{}, params)
      assert validity
      assert {:ok, _workflow} = Repo.insert(changeset)
    end
  end

  describe "update_changeset/1 " do
    setup do
      project = insert(:project)
      workflow = insert(:workflow, %{project: project, org: project.org})
      [workflow: workflow]
    end

    test "returns a valid changeset", %{workflow: workflow} do
      update_params = %{name: "WorkflowXY", enabled: false, digraph: %{}}
      %{valid?: validity} = Workflow.update_changeset(workflow, update_params)

      assert validity
    end
  end
end
