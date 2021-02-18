defmodule AcqdatApiWeb.DataCruncher.TasksControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "show/2" do
    setup :setup_conn

    setup do
      task = insert(:tasks)

      [task: task]
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        id: 3
      }

      conn = get(conn, Routes.user_tasks_path(conn, :show, 1, 1, params.id))
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "task with invalid task id", %{conn: conn, task: task} do
      params = %{
        id: -1
      }

      conn =
        get(
          conn,
          Routes.user_tasks_path(conn, :show, task.org_id, task.user_id, params.id)
        )

      result = conn |> json_response(400)

      assert result == %{
               "detail" => "Task with this ID does not exists",
               "source" => nil,
               "status_code" => 400,
               "title" => "Invalid entity ID"
             }
    end

    test "task with valid id", %{conn: conn, task: task} do
      conn =
        get(
          conn,
          Routes.user_tasks_path(conn, :show, task.org_id, task.user_id, task.id)
        )

      result = conn |> json_response(200)

      refute is_nil(result)

      assert Map.has_key?(result, "id")
      assert Map.has_key?(result, "name")
    end
  end

  describe "delete/2" do
    setup :setup_conn

    setup do
      task = insert(:tasks)

      [task: task]
    end

    test "task delete", %{conn: conn, task: task} do
      conn =
        delete(
          conn,
          Routes.user_tasks_path(
            conn,
            :delete,
            task.org_id,
            task.user_id,
            task.id
          )
        )

      response = conn |> json_response(200)

      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        id: 3
      }

      conn = delete(conn, Routes.user_tasks_path(conn, :delete, 1, 1, params.id))
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "task with invalid task id", %{conn: conn} do
      params = %{
        id: -1
      }

      conn = delete(conn, Routes.user_tasks_path(conn, :delete, 1, 1, params.id))

      result = conn |> json_response(404)

      assert result == %{
               "detail" => "Task with this ID does not exists",
               "source" => nil,
               "status_code" => 404,
               "title" => "Invalid entity ID"
             }
    end
  end

  describe "index/2" do
    setup :setup_conn

    test "fetch all tasks", %{conn: conn} do
      task = insert(:tasks)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn =
        get(
          conn,
          Routes.user_tasks_path(conn, :index, task.org_id, task.user_id, params)
        )

      response = conn |> json_response(200)

      assert length(response["tasks"]) == 1
      assertion_task = List.first(response["tasks"])
      assert assertion_task["id"] == task.id
      assert assertion_task["name"] == task.name
    end

    test "if params are missing", %{conn: conn} do
      task = insert(:tasks)

      conn =
        get(
          conn,
          Routes.user_tasks_path(conn, :index, task.org_id, task.user_id, %{})
        )

      response = conn |> json_response(200)
      assert response["total_pages"] == 1
      assert length(response["tasks"]) == response["total_entries"]
    end

    test "Pagination", %{conn: conn} do
      task = insert(:tasks)

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn =
        get(
          conn,
          Routes.user_tasks_path(conn, :index, task.org_id, task.user_id, params)
        )

      page1_response = conn |> json_response(200)
      assert page1_response["page_number"] == params["page_number"]
      assert page1_response["page_size"] == params["page_size"]
      assert page1_response["total_pages"] == 1
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"
      task = insert(:tasks)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn =
        get(
          conn,
          Routes.user_tasks_path(conn, :index, task.org_id, task.user_id, params)
        )

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end
  end
end
