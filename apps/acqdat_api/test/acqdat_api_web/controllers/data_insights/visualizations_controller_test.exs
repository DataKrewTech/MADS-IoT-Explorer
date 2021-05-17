defmodule AcqdatApiWeb.DataInsights.VisualizationsControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "fetch_all_types/2" do
    setup :setup_conn

    setup do
      project = insert(:project)
      user = insert(:user)

      [user: user, project: project]
    end

    test "list all types of available visualizations type metadata", %{
      conn: conn,
      project: project
    } do
      conn =
        get(conn, Routes.visualizations_path(conn, :fetch_all_types, project.org_id, project.id))

      response = conn |> json_response(200)

      assert length(response["visualizations"]) == 5
    end

    test "fails if authorization header not found", %{conn: conn, project: project} do
      bad_access_token = "qwerty1234567uiop"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(conn, Routes.visualizations_path(conn, :fetch_all_types, project.org_id, project.id))

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end
  end

  describe "create/2" do
    setup :setup_conn

    setup do
      project = insert(:project)
      user = insert(:user)
      fact_table = insert(:fact_tables)

      [user: user, project: project, fact_table: fact_table]
    end

    test "visualizations create", %{
      conn: conn,
      user: user,
      project: project,
      fact_table: fact_table
    } do
      data = %{
        name: "line visualizations 1.1",
        type: "Lines",
        module: "Elixir.AcqdatCore.DataInsights.Schema.Visualizations.Lines",
        creator_id: user.id,
        fact_table_id: fact_table.id
      }

      conn =
        post(
          conn,
          Routes.fact_tables_visualizations_path(
            conn,
            :create,
            project.org_id,
            project.id,
            fact_table.id
          ),
          data
        )

      response = conn |> json_response(200)

      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      assert response["type"] == "Lines"
      assert response["name"] == "line visualizations 1.1"
      assert response["module"] == "Elixir.AcqdatCore.DataInsights.Schema.Visualizations.Lines"
    end

    test "fails if authorization header not found", %{
      conn: conn,
      project: project,
      fact_table: fact_table
    } do
      bad_access_token = "qwerty1234567uiop"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}

      conn =
        post(
          conn,
          Routes.fact_tables_visualizations_path(
            conn,
            :create,
            project.org_id,
            project.id,
            fact_table.id
          ),
          data
        )

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "fails if required params are missing", %{
      conn: conn,
      project: project,
      fact_table: fact_table
    } do
      data = %{}

      conn =
        post(
          conn,
          Routes.fact_tables_visualizations_path(
            conn,
            :create,
            project.org_id,
            project.id,
            fact_table.id
          ),
          data
        )

      response = conn |> json_response(400)

      assert response["source"] == %{
               "name" => ["can't be blank"],
               "creator_id" => ["can't be blank"],
               "fact_table_id" => ["can't be blank"],
               "module" => ["can't be blank"],
               "type" => ["can't be blank"]
             }
    end
  end

  describe "index/2" do
    setup :setup_conn

    setup do
      [visualization1, visualization2, visualization3] = insert_list(3, :visualizations)

      [
        visualization1: visualization1,
        visualization2: visualization2,
        visualization3: visualization3
      ]
    end

    test "fetch all visualizations", %{conn: conn, visualization1: visualization1} do
      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn =
        get(
          conn,
          Routes.fact_tables_visualizations_path(
            conn,
            :index,
            visualization1.org_id,
            visualization1.project_id,
            visualization1.fact_table_id,
            params
          )
        )

      response = conn |> json_response(200)

      assert length(response["visualizations"]) == 1
    end

    test "if params are missing", %{conn: conn, visualization1: visualization1} do
      conn =
        get(
          conn,
          Routes.fact_tables_visualizations_path(
            conn,
            :index,
            visualization1.org_id,
            visualization1.project_id,
            visualization1.fact_table_id,
            %{}
          )
        )

      response = conn |> json_response(200)
      assert response["total_pages"] == 1
      assert length(response["visualizations"]) == response["total_entries"]
    end

    test "fails if invalid token in authorization header", %{
      conn: conn,
      visualization1: visualization1
    } do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(
          conn,
          Routes.fact_tables_visualizations_path(
            conn,
            :index,
            visualization1.org_id,
            visualization1.project_id,
            visualization1.fact_table_id,
            %{}
          )
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

  describe "delete/2" do
    setup :setup_conn

    setup do
      visualizations = insert(:visualizations)

      [visualizations: visualizations]
    end

    test "visualizations delete", %{conn: conn, visualizations: visualizations} do
      conn =
        delete(
          conn,
          Routes.fact_tables_visualizations_path(
            conn,
            :delete,
            1,
            visualizations.project_id,
            visualizations.fact_table_id,
            visualizations.id
          )
        )

      response = conn |> json_response(200)

      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end

    test "fails if invalid token in authorization header", %{
      conn: conn,
      visualizations: visualizations
    } do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        delete(
          conn,
          Routes.fact_tables_visualizations_path(
            conn,
            :delete,
            1,
            visualizations.project_id,
            visualizations.fact_table_id,
            visualizations.id
          )
        )

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "fact_table with invalid visualizations id", %{
      conn: conn,
      visualizations: visualizations
    } do
      conn =
        delete(
          conn,
          Routes.fact_tables_visualizations_path(
            conn,
            :delete,
            1,
            visualizations.project_id,
            visualizations.fact_table_id,
            -1
          )
        )

      result = conn |> json_response(404)

      assert result == %{
               "detail" => "Visualization with this ID doesn't exists",
               "source" => nil,
               "status_code" => 404,
               "title" => "Invalid entity ID"
             }
    end
  end

  describe "show/2" do
    setup :setup_conn

    setup do
      visualizations = insert(:visualizations)

      [visualizations: visualizations]
    end

    test "visualizations show", %{conn: conn, visualizations: visualizations} do
      conn =
        get(
          conn,
          Routes.fact_tables_visualizations_path(
            conn,
            :show,
            1,
            visualizations.project_id,
            visualizations.fact_table_id,
            visualizations.id
          )
        )

      response = conn |> json_response(200)

      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      assert response["id"] == visualizations.id
    end

    test "fails if invalid token in authorization header", %{
      conn: conn,
      visualizations: visualizations
    } do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(
          conn,
          Routes.fact_tables_visualizations_path(
            conn,
            :show,
            1,
            visualizations.project_id,
            visualizations.fact_table_id,
            visualizations.id
          )
        )

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "fact_table with invalid visualizations id", %{
      conn: conn,
      visualizations: visualizations
    } do
      conn =
        get(
          conn,
          Routes.fact_tables_visualizations_path(
            conn,
            :show,
            1,
            visualizations.project_id,
            visualizations.fact_table_id,
            -1
          )
        )

      result = conn |> json_response(404)

      assert result == %{
               "detail" => "Visualization with this ID doesn't exists",
               "source" => nil,
               "status_code" => 404,
               "title" => "Invalid entity ID"
             }
    end
  end

  describe "export/2" do
    setup :setup_conn

    setup do
      widget = insert(:widget, label: "line")
      visualizations = insert(:visualizations)

      panel = insert(:panel)

      [visualizations: visualizations, panel: panel, widget: widget]
    end

    test "visualizations export", %{
      conn: conn,
      visualizations: visualizations,
      panel: panel,
      widget: widget
    } do
      data = %{
        title: "exported visualizations 1.1",
        panel_id: panel.id
      }

      conn =
        post(
          conn,
          Routes.fact_tables_visualizations_visualizations_path(
            conn,
            :export,
            1,
            visualizations.project_id,
            visualizations.fact_table_id,
            visualizations.id
          ),
          data
        )

      response = conn |> json_response(200)

      assert Map.has_key?(response, "id")
      assert response["label"] == "exported visualizations 1.1"
      assert response["source_app"] == "data_insights"
      assert response["panel"]["id"] == panel.id
      assert response["widget_id"] == widget.id
      assert response["visual_properties"]["title"]["text"] == "exported visualizations 1.1"
    end

    test "fails if invalid token in authorization header", %{
      conn: conn,
      visualizations: visualizations
    } do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        post(
          conn,
          Routes.fact_tables_visualizations_visualizations_path(
            conn,
            :export,
            1,
            visualizations.project_id,
            visualizations.fact_table_id,
            visualizations.id
          ),
          %{}
        )

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "export with invalid visualizations id", %{
      conn: conn,
      visualizations: visualizations
    } do
      conn =
        post(
          conn,
          Routes.fact_tables_visualizations_visualizations_path(
            conn,
            :export,
            1,
            visualizations.project_id,
            visualizations.fact_table_id,
            -1
          ),
          %{}
        )

      result = conn |> json_response(404)

      assert result == %{
               "detail" => "Visualization with this ID doesn't exists",
               "source" => nil,
               "status_code" => 404,
               "title" => "Invalid entity ID"
             }
    end
  end
end
