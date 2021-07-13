defmodule AcqdatApiWeb.ElasticSearch.ProjectControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Factory.ElasticSearch.Project
  import AcqdatCore.Support.Factory

  describe "search_projects/2" do
    setup :setup_conn

    setup do
      project = insert(:project)
      Project.create_index()
      Project.seed_project(project)
      :timer.sleep(2500)

      on_exit(fn ->
        Project.delete_index()
      end)

      [project: project]
    end

    test "fails if authorization header not found", %{conn: conn, project: project} do
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(conn, Routes.search_projects_path(conn, :search_projects, project.org.id), %{
          "label" => project.name
        })

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "search with valid params", %{conn: conn, project: project} do
      conn =
        get(conn, Routes.search_projects_path(conn, :search_projects, project.org.id), %{
          "label" => project.name,
          "is_archived" => false
        })

      %{"projects" => [rproject]} = conn |> json_response(200)

      assert rproject["archived"] == project.archived

      assert rproject["creator_id"] == project.creator_id

      assert rproject["id"] == project.id

      assert rproject["metadata"] == project.metadata
      assert rproject["name"] == project.name
      assert rproject["slug"] == project.slug
      assert rproject["start_date"] == project.start_date
    end

    test "search with no hits", %{conn: conn, project: project} do
      conn =
        get(conn, Routes.search_projects_path(conn, :search_projects, project.org.id), %{
          "label" => "Random Name ?",
          "is_archived" => false
        })

      result = conn |> json_response(200)

      assert result == %{
               "projects" => [],
               "total_entries" => 0
             }
    end
  end

  describe "index projects/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      Project.create_index()
      [project1, project2, project3] = Project.seed_multiple_project(org, 3)
      :timer.sleep(2500)

      on_exit(fn ->
        Project.delete_index()
      end)

      [project1: project1, project2: project2, project3: project3]
    end

    test "fails if authorization header not found", %{conn: conn, org: org} do
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(conn, Routes.project_path(conn, :index, org.id), %{
          "from" => 0,
          "page_size" => 1,
          "is_archived" => false
        })

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "index with valid params and multiple entries", %{
      conn: conn,
      project1: project1,
      project2: project2,
      project3: project3
    } do
      conn =
        get(conn, Routes.project_path(conn, :index, project1.org.id), %{
          "from" => 0,
          "page_size" => 3,
          "is_archived" => false
        })

      %{"projects" => projects} = conn |> json_response(200)

      assert length(projects) == 3
      [rproject1, rproject2, rproject3] = projects
      assert rproject1["id"] == project1.id
      assert rproject2["id"] == project2.id
      assert rproject3["id"] == project3.id
    end
  end
end
