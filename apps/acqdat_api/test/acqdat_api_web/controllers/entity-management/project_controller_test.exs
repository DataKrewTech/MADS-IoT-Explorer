defmodule AcqdatApiWeb.EntityManagement.ProjectControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

    describe "index/2" do
    setup :setup_conn

    test "Project Data", %{conn: conn, org: org} do
      test_project = insert(:project)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn = get(conn, Routes.project_path(conn, :index, test_project.org_id, params))
      response = conn |> json_response(200)
      assert length(response["projects"]) == 1
      assertion_project = List.first(response["projects"])
      assert assertion_project["id"] == test_project.id
      assert assertion_project["archived"] == test_project.archived
      assert assertion_project["description"] == test_project.description
      assert assertion_project["name"] == test_project.name
      assert assertion_project["org_id"] == test_project.org_id
      assert assertion_project["slug"] == test_project.slug
      assert assertion_project["version"] == test_project.version
    end

    test "if params are missing", %{conn: conn, org: org} do
      insert_list(3, :project)
      conn = get(conn, Routes.project_path(conn, :index, org.id, %{}))
      response = conn |> json_response(200)
      assert response["total_pages"] == 1
      assert length(response["projects"]) == response["total_entries"]
    end

    test "Big page size", %{conn: conn, org: org} do
      insert_list(3, :project)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn = get(conn, Routes.project_path(conn, :index, org.id, params))
      response = conn |> json_response(200)
      assert response["page_number"] == params["page_number"]
      assert response["page_size"] == params["page_size"]
      assert response["total_pages"] == 1
      assert length(response["projects"]) == response["total_entries"]
    end

    test "Pagination", %{conn: conn, org: org} do
      [project1, project2, project3] = insert_list(3, :project)

      params = %{
        "page_size" => 1,
        "page_number" => 1
      }

      conn = get(conn, Routes.project_path(conn, :index, project1.org_id, params))
      page1_response = conn |> json_response(200)
      assert page1_response["page_number"] == params["page_number"]
      assert page1_response["page_size"] == params["page_size"]
      assert page1_response["total_pages"] == 1
      assert length(page1_response["projects"]) == page1_response["page_size"]
    end

    test "fails if invalid token in authorization header", %{conn: conn, org: org} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn = get(conn, Routes.project_path(conn, :index, org.id, params))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end
end
