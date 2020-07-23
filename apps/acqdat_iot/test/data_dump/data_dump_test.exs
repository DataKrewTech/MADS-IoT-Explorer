defmodule AcqdatIotWeb.DataDump do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  use AcqdatIotWeb.ConnCase
  import Plug.Conn
  alias AcqdatCore.Test.Support.DataDump

  describe "create/2" do
    setup %{} do
      # Setting the shared mode so the internal processes share the same db
      # conneciton.
      Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    end

    setup :setup_gateway

    test "data dump create", %{conn: conn, org: org, gateway: gateway, data_dump: data_dump} do
      project = gateway.project
      params = data_dump

      conn =
        post(conn, Routes.data_dump_path(conn, :create, org.id, project.id, gateway.id), params)

      # TODO: have added a small time out so worker processes release db
      # connection, else the test exits and db connection is removed.
      # Need to add a clean way to handle this.
      :timer.sleep(50)
      result = conn |> json_response(202)
      assert result == %{"data inserted" => true}
    end

    test "fails if authorization header not found", %{conn: conn, org: org, gateway: gateway} do
      bad_access_token = "qwerty1234567uiop"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}

      conn =
        post(
          conn,
          Routes.data_dump_path(conn, :create, org.id, gateway.project.id, gateway.id),
          data
        )

      result = conn |> json_response(404)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "index/2" do
    setup %{} do
      # Setting the shared mode so the internal processes share the same db
      # conneciton.
      Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    end

    setup :setup_gateway

    test "list data of a particular gateway", %{conn: conn, org: org, gateway: gateway} do
      params = %{
        "page_size" => 1,
        "page_number" => 1
      }

      DataDump.insert_multiple_datadumps(gateway)

      conn =
        get(
          conn,
          Routes.data_dump_path(conn, :index, org.id, gateway.project.id, gateway.id, params)
        )

      response = conn |> json_response(200)
      [data_dump] = response["data_dumps"]

      assert response ==
               %{
                 "data_dumps" => [
                   %{
                     "data" => %{
                       "axis_object" => %{
                         "lambda" => %{"alpha" => 24, "beta" => 25},
                         "x_axis" => 20,
                         "z_axis" => [22, 23]
                       },
                       "y_axis" => 21
                     },
                     "gateway_id" => gateway.id,
                     "inserted_timestamp" => data_dump["inserted_timestamp"]
                   }
                 ],
                 "page_number" => params["page_number"],
                 "page_size" => params["page_size"],
                 "total_entries" => response["total_entries"],
                 "total_pages" => response["total_pages"]
               }
    end

    test "fails if invalid token in authorization header", %{
      conn: conn,
      org: org,
      gateway: gateway
    } do
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
          Routes.data_dump_path(conn, :index, org.id, gateway.project.id, gateway.id, params)
        )

      result = conn |> json_response(404)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  def setup_gateway(%{conn: conn}) do
    [data_dump, _sensor1, _sensor2, gateway] = DataDump.setup_gateway()

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer #{gateway.access_token}")

    [conn: conn, org: gateway.org, gateway: gateway, data_dump: data_dump]
  end
end
