defmodule AcqdatApiWeb.StreamLogic.WorkflowControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatApiWeb.StreamLogic.WorkflowController

  describe "index/1 " do
    setup :setup_conn
    setup do
      project = insert(:project)
      [project: project]
    end

    test "returns a list of workflows", context do
      %{project: project, conn: conn} = context
      org = project.org
      digraph = create_digraph()
      entries = 6
      insert_list(entries, :workflow, project: project, org: org, digraph: digraph)

      params = %{
        page_size: 2,
        page_number: 1
      }
      conn = get(conn, Routes.workflow_path(conn, :index, org.id, project.id), params)
      result = conn |> json_response(200)
      assert result["page_size"] == params.page_size
      assert result["page_number"] == params.page_number
      assert result["total_entries"] == entries
    end

    test "returns error for bad request", %{conn: conn} do
      params = %{
        page_size: 2,
        page_number: 1
      }

      result = WorkflowController.index(conn, params) |> json_response(400)
      assert %{
        "errors" => %{
          "message" => %{
            "org_id" => ["can't be blank"],
            "project_id" => ["can't be blank"]
          }
        }
      } == result
    end
  end

  describe "create/2 " do
    setup :setup_conn
    setup do
      project = insert(:project)
      [project: project]
    end

    test "creates a project and returns it", context do
      %{project: project, conn: conn} = context
      org = project.org
      digraph = create_digraph()
      params = params_for(:workflow, project: project, org: org,
        digraph: digraph)

      conn = post(conn, Routes.workflow_path(conn, :create, org.id, project.id),
        params)
      result = conn |> json_response(200)
      assert result["name"] == params.name
      assert Map.has_key?(result, "id")
      assert Map.has_key?(result, "digraph")
      assert Map.has_key?(result, "metadata")
    end

    test "returns error if project not found", context do
      %{project: project, conn: conn} = context
      org = project.org
      digraph = create_digraph()
      params = params_for(:workflow, project: project, org: org, digraph: digraph)

      conn = post(conn, Routes.workflow_path(conn, :create, org.id, -1), params)
      result = conn |> json_response(404)
      assert %{"errors" => %{"message" => "Project not found"}} == result
    end

    test "returns error for duplicate workflow", context do
      %{project: project, conn: conn} = context
      org = project.org
      workflow = insert(:workflow, project: project, org: org)
      params = params_for(:workflow, project: project, org: org,
        name: workflow.name)

      conn = post(conn, Routes.workflow_path(conn, :create, org.id, project.id),
        params)
      result = conn |> json_response(400)
      assert %{
        "errors" => %{
          "message" => %{"error" =>
            %{"name" => ["workflow with this name exists"]}}
        }
      } == result
    end
  end

  describe "update/2 " do
    setup :setup_conn
    setup do
      project = insert(:project)
      workflow = insert(:workflow, project: project, org: project.org)
      [project: project, workflow: workflow]
    end

    test "udpates a workflow", context do
      %{workflow: workflow, project: project, conn: conn} = context
      org = project.org
      digraph = create_digraph()
      update_params = %{name: "StreamifyX", digraph: digraph}

      conn = put(conn,
        Routes.workflow_path(conn, :update, org.id, project.id, workflow.id),
        update_params
      )

      result = conn |> json_response(200)
      assert result["id"] == workflow.id
      refute result["name"] == workflow.name
    end

    test "returns error message for any changeset error", context do
      %{workflow: workflow, project: project, conn: conn} = context
      org = project.org
      workflow_other = insert(:workflow, project: project, org: org)
      update_params = %{name: workflow.name}

      conn = put(conn,
        Routes.workflow_path(conn, :update, org.id, project.id, workflow_other.id),
        update_params
      )
      result = conn |> json_response(400)
      assert %{"errors" => %{"message" =>
        %{"name" => ["workflow with this name exists"]}
      }} == result
    end

    test "returns error if not found", context do
      %{project: project, conn: conn} = context
      org = project.org
      update_params = %{name: "abc"}

      conn = put(conn,
        Routes.workflow_path(conn, :update, org.id, project.id, -1),
        update_params
      )
      result = conn |> json_response(404)
      assert %{"errors" => %{"message" => "workflow not found"}} == result
    end
  end

  describe "show/2 " do
    setup :setup_conn
    setup do
      project = insert(:project)
      workflow = insert(:workflow, project: project, org: project.org)
      [project: project, workflow: workflow]
    end

    test "returns a workflow", context do
      %{conn: conn, project: project, workflow: workflow} = context
      org = project.org

      conn = get(conn, Routes.workflow_path(conn, :show, org.id, project.id, workflow.id))
      result = conn |> json_response(200)
      assert result["id"]  == workflow.id
    end

    test "returns error if not found", context do
      %{conn: conn, project: project} = context
      org = project.org
      conn = get(conn, Routes.workflow_path(conn, :show, org.id, project.id, -1))
      result = conn |> json_response(404)
      assert result == %{"errors" => %{"message" => "workflow not found"}}
    end
  end

  describe "delete/2 " do
    setup :setup_conn
    setup do
      project = insert(:project)
      workflow = insert(:workflow, project: project, org: project.org)
      [project: project, workflow: workflow]
    end

    test "deletes and returns deleted record", context do
      %{conn: conn, project: project, workflow: workflow} = context
      org = project.org
      conn = delete(conn, Routes.workflow_path(conn, :delete, org.id,
        project.id, workflow.id))

      result = conn |> json_response(200)
      assert Map.has_key?(result, "id")
      assert Map.has_key?(result, "name")
    end

    test "returns error if not found", context do
      %{conn: conn, project: project} = context
      org = project.org
      conn = delete(conn, Routes.workflow_path(conn, :delete, org.id,
        project.id, -1))

      result = conn |> json_response(404)
      assert result == %{"errors" => %{"message" => "workflow not found"}}
    end
  end
end
