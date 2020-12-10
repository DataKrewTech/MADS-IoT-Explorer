defmodule AcqdatApiWeb.ElasticSearch.ProjectControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Factory.ElasticSearch.Project
  import AcqdatCore.Support.Factory

  describe "search_projects/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn, org: org} do
      project = insert(:project, org: org)
      Project.create_index()
      Project.seed_project(project)
      :timer.sleep(2500)
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(conn, Routes.search_projects_path(conn, :search_projects, org.id), %{
          "label" => project.name
        })

      result = conn |> json_response(403)
      Project.delete_index()
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "search with valid params", %{conn: conn, org: org} do
      project = insert(:project, org: org)
      Project.create_index()
      Project.seed_project(project)
      :timer.sleep(2500)

      conn =
        get(conn, Routes.search_projects_path(conn, :search_projects, org.id), %{
          "label" => project.name
        })

      %{"projects" => [rproject]} = conn |> json_response(200)

      Project.delete_index()
      assert rproject["archived"] == project.archived

      assert rproject["creator_id"] == project.creator_id

      assert rproject["id"] == project.id

      assert rproject["metadata"] == project.metadata
      assert rproject["name"] == project.name
      assert rproject["slug"] == project.slug
      assert rproject["start_date"] == project.start_date
    end

    test "search with no hits", %{conn: conn, org: org} do
      project = insert(:project)
      Project.create_index()
      Project.seed_project(project)
      :timer.sleep(2500)

      conn =
        get(conn, Routes.search_projects_path(conn, :search_projects, org.id), %{
          "label" => project.name
        })

      result = conn |> json_response(200)
      Project.delete_index()

      assert result == %{
               "projects" => [],
               "total_entries" => 1
             }
    end
  end

  describe "index projects/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn, org: org} do
      Project.create_index()
      Project.seed_multiple_project(org)
      :timer.sleep(2500)
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(conn, Routes.project_path(conn, :index, org.id), %{
          "from" => 0,
          "page_size" => 1
        })

      result = conn |> json_response(403)
      Project.delete_index()
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "index with valid params and multiple entries", %{conn: conn, org: org} do
      Project.create_index()
      [project1, project2, project3] = Project.seed_multiple_project(org)
      :timer.sleep(2500)

      conn =
        get(conn, Routes.project_path(conn, :index, org.id), %{
          "from" => 0,
          "page_size" => 3
        })

      %{"projects" => projects} = conn |> json_response(200)

      Project.delete_index()
      assert length(projects) == 3
      [rproject1, rproject2, rproject3] = projects
      assert rproject1["id"] == project1.id
      assert rproject2["id"] == project2.id
      assert rproject3["id"] == project3.id
    end
  end
end
