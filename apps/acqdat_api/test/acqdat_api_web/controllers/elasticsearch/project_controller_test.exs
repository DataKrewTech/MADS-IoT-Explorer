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
      # :timer.sleep(2500)

      on_exit(fn ->
        Project.delete_index()
      end)

      [project: project]
    end

    # test "fails if authorization header not found", %{conn: conn, project: project} do
    #   bad_access_token = "avcbd123489u"

    #   conn =
    #     conn
    #     |> put_req_header("authorization", "Bearer #{bad_access_token}")

    #   conn =
    #     get(conn, "/role_mgmt/orgs/#{project.org.id}/projects/search", %{
    #       "label" => project.name
    #     })

    #   result = conn |> json_response(403)

    #   assert result == %{
    #            "detail" => "You are not allowed to perform this action.",
    #            "source" => nil,
    #            "status_code" => 403,
    #            "title" => "Unauthorized"
    #          }
    # end

    # test "search with valid params", %{conn: conn, project: project} do
    #   conn =
    #     get(conn, "/role_mgmt/orgs/#{project.org.id}/projects/search", %{
    #       "label" => project.name,
    #       "is_archived" => false
    #     })

    #   %{"projects" => [rproject]} = conn |> json_response(200)

    #   assert rproject["archived"] == project.archived

    #   assert rproject["creator_id"] == project.creator_id

    #   assert rproject["id"] == project.id

    #   assert rproject["metadata"] == project.metadata
    #   assert rproject["name"] == project.name
    #   assert rproject["slug"] == project.slug
    #   assert rproject["start_date"] == project.start_date
    # end

    test "search with no hits", %{conn: conn, project: project} do
      IO.inspect(Routes.role_management_search_projects_path(conn, :search_projects, project.org.id))
      conn =
        get(conn, Routes.role_management_search_projects_path(conn, :search_projects, project.org.id), %{
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

  describe "archived/2" do

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

    # Command - GET /role_mgmt/orgs/:org_id/archived_projects

  end

  describe "update/2" do

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

    # Command - PATCH (or PUT?) /role_mgmt/orgs/:org_id/projects/:id

  end

  # describe "create/2" do

  #   setup :setup_conn

  #   setup do
  #     project = insert(:project)
  #     Project.create_index()
  #     Project.seed_project(project)
  #     :timer.sleep(2500)

  #     on_exit(fn ->
  #       Project.delete_index()
  #     end)

  #     [project: project]
  #   end

  #   test "creates successfully", %{conn: conn, project: irrelevant_project} do
  #     conn = post(conn, "/role_mgmt/orgs/#{irrelevant_project.org.id}/projects", %{
  #       "name" => "project204"
  #     })
  #     conn |> json_response(200) |> IO.inspect()
  #   end

  # end

  # describe "delete/2" do

  #   setup :setup_conn

  #   setup do
  #     project = insert(:project)
  #     Project.create_index()
  #     Project.seed_project(project)
  #     :timer.sleep(2500)

  #     # on_exit(fn ->
  #     #   Project.delete_index()
  #     # end)

  #     [project: project]
  #   end

  #   test "deletes successfully with valid params", %{conn: conn, project: project} do
  #     conn = delete(conn, "/role_mgmt/orgs/#{project.org.id}/projects/#{project.id}")
  #     IO.inspect(conn)
  #   end

  # end

  # describe "fetch_project_users/2" do

  #   setup :setup_conn

  #   setup do
  #     project = insert(:project)
  #     Project.create_index()
  #     Project.seed_project(project)
  #     :timer.sleep(2500)

  #     on_exit(fn ->
  #       Project.delete_index()
  #     end)

  #     [project: project]
  #   end

  #   # Command - GET /role_mgmt/orgs/:org_id/projects/:project_id/users

  # end
end
