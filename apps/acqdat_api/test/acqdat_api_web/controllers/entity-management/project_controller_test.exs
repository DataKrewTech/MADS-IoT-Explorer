defmodule AcqdatApiWeb.EntityManagement.ProjectControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      user = insert(:user)
      [org: org, user: user]
    end

    test "project create", %{conn: conn, org: org, user: user} do
      project = build(:project)

      data = %{
        name: project.name,
        creator_id: user.id
      }

      conn = post(conn, Routes.project_path(conn, :create, org.id), data)
      response = conn |> json_response(200)

      assert response = %{
               "archived" => project.archived,
               "creator_id" => user.id,
               "name" => project.name,
               "org_id" => org.id,
               "slug" => project.slug,
               "type" => "Project",
               "version" => project.version
             }
    end

    test "fails if authorization header not found", %{conn: conn, org: org, user: user} do
      bad_access_token = "qwerty1234567uiop"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{
        creator_id: user.id
      }

      conn = post(conn, Routes.project_path(conn, :create, org.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if sent params are not unique", %{conn: conn, org: org, user: user} do
      project = insert(:project)

      data = %{
        name: project.name,
        creator_id: project.creator_id
      }

      conn = post(conn, Routes.project_path(conn, :create, project.org_id), data)
      response = conn |> json_response(400)

      assert response == %{
               "errors" => %{
                 "message" => %{"error" => %{"name" => ["unique name under organisation"]}}
               }
             }
    end

    test "fails if required params are missing", %{conn: conn, org: org, user: user} do
      conn = post(conn, Routes.project_path(conn, :create, org.id), %{})
      response = conn |> json_response(400)

      assert response == %{
               "errors" => %{
                 "message" => %{
                   "name" => ["can't be blank"],
                   "creator_id" => ["can't be blank"]
                 }
               }
             }
    end
  end

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

  describe "update/2" do
    setup :setup_conn

    test "project update", %{conn: conn} do
      project = insert(:project)
      data = Map.put(%{}, :name, "Water Project")

      conn = put(conn, Routes.project_path(conn, :update, project.org_id, project.id), data)
      response = conn |> json_response(200)

      assert response = %{
               "archived" => project.archived,
               "creator_id" => project.creator_id,
               "name" => project.name,
               "org_id" => project.org_id,
               "slug" => project.slug,
               "type" => "Project",
               "version" => project.version
             }
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty12345678qwer"
      project = insert(:project)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = Map.put(%{}, :name, "Water Project")
      conn = put(conn, Routes.project_path(conn, :update, project.org_id, project.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "delete/2" do
    setup :setup_conn

    test "project delete", %{conn: conn} do
      project = insert(:project)

      conn = delete(conn, Routes.project_path(conn, :delete, project.org_id, project.id))
      response = conn |> json_response(200)

      assert response = %{
               "archived" => project.archived,
               "creator_id" => project.creator_id,
               "name" => project.name,
               "org_id" => project.org_id,
               "slug" => project.slug,
               "type" => "Project",
               "version" => project.version
             }
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      project = insert(:project)
      bad_access_token = "qwerty1234567qwerty"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = delete(conn, Routes.project_path(conn, :delete, project.org_id, project.id))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end
end
