defmodule AcqdatApiWeb.DataInsights.FactTablesControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      project = insert(:project)

      [org: org, project: project]
    end

    test "fact table create", %{conn: conn, org: org, project: project} do
      data = %{
        name: "fact table 1.1"
      }

      conn = post(conn, Routes.fact_tables_path(conn, :create, org.id, project.id), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end

    test "fails if authorization header not found", %{conn: conn, org: org, project: project} do
      bad_access_token = "qwerty1234567uiop"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.fact_tables_path(conn, :create, org.id, project.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if required params are missing", %{conn: conn, org: org, project: project} do
      data = %{}

      conn = post(conn, Routes.fact_tables_path(conn, :create, org.id, project.id), data)

      response = conn |> json_response(400)

      assert response == %{
               "errors" => %{
                 "message" => %{
                   "name" => ["can't be blank"]
                 }
               }
             }
    end
  end

  describe "index/2" do
    setup :setup_conn

    setup do
      [fact_table1, fact_table2, fact_table3] = insert_list(3, :fact_tables)

      [fact_table1: fact_table1, fact_table2: fact_table2, fact_table3: fact_table3]
    end

    test "fetch all fact_tables", %{conn: conn, fact_table1: fact_table1} do
      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn =
        get(
          conn,
          Routes.fact_tables_path(
            conn,
            :index,
            fact_table1.org_id,
            fact_table1.project_id,
            params
          )
        )

      response = conn |> json_response(200)

      assert length(response["fact_tables"]) == 1
    end

    test "if params are missing", %{conn: conn, fact_table1: fact_table1} do
      conn =
        get(
          conn,
          Routes.fact_tables_path(conn, :index, fact_table1.org_id, fact_table1.project_id, %{})
        )

      response = conn |> json_response(200)
      assert response["total_pages"] == 1
      assert length(response["fact_tables"]) == response["total_entries"]
    end

    test "fails if invalid token in authorization header", %{conn: conn, fact_table1: fact_table1} do
      bad_access_token = "qwerty1234567qwerty12"

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
          Routes.fact_tables_path(
            conn,
            :index,
            fact_table1.org_id,
            fact_table1.project_id,
            params
          )
        )

      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "details/2" do
    setup :setup_conn

    setup do
      fact_table = insert(:fact_tables)

      [fact_table: fact_table]
    end

    test "fails if invalid token in authorization header", %{conn: conn, fact_table: fact_table} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        id: 3
      }

      conn =
        get(
          conn,
          Routes.fact_tables_fact_tables_path(
            conn,
            :details,
            fact_table.org_id,
            fact_table.project_id,
            params.id
          )
        )

      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fact_table with invalid fact_table id", %{conn: conn, fact_table: fact_table} do
      params = %{
        id: -1
      }

      conn =
        get(
          conn,
          Routes.fact_tables_fact_tables_path(
            conn,
            :details,
            fact_table.org_id,
            fact_table.project_id,
            params.id
          )
        )

      result = conn |> json_response(404)
      assert result == %{"errors" => %{"message" => "Resource Not Found"}}
    end

    test "fact_table with valid id", %{conn: conn, fact_table: fact_table} do
      conn =
        get(
          conn,
          Routes.fact_tables_fact_tables_path(
            conn,
            :details,
            fact_table.org_id,
            fact_table.project_id,
            fact_table.id
          )
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
      fact_table = insert(:fact_tables)

      [fact_table: fact_table]
    end

    test "fact_table delete", %{conn: conn, fact_table: fact_table} do
      conn =
        delete(
          conn,
          Routes.fact_tables_path(
            conn,
            :delete,
            fact_table.org_id,
            fact_table.project_id,
            fact_table.id
          )
        )

      response = conn |> json_response(200)

      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end

    test "fails if invalid token in authorization header", %{conn: conn, fact_table: fact_table} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        id: 3
      }

      conn =
        delete(
          conn,
          Routes.fact_tables_path(
            conn,
            :delete,
            fact_table.org_id,
            fact_table.project_id,
            params.id
          )
        )

      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fact_table with invalid fact_table id", %{conn: conn, fact_table: fact_table} do
      params = %{
        id: -1
      }

      conn =
        delete(
          conn,
          Routes.fact_tables_path(
            conn,
            :delete,
            fact_table.org_id,
            fact_table.project_id,
            params.id
          )
        )

      result = conn |> json_response(404)
      assert result == %{"errors" => %{"message" => "Resource Not Found"}}
    end
  end
end
