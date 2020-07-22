defmodule AcqdatIotWeb.DataDump do
  use ExUnit.Case, async: false
  use AcqdatCore.DataCase
  use AcqdatIotWeb.ConnCase
  import Plug.Conn
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_gateway

    test "data dump create", %{conn: conn, org: org, gateway: gateway} do
      project = gateway.project

      params = %{
        data: %{
          axis_object: %{
            x_axis: 20,
            y_axis: 21
          }
        },
        inserted_timestamp: "2019-08-07T10:10:01Z"
      }

      conn =
        post(conn, Routes.data_dump_path(conn, :create, org.id, project.id, gateway.id), params)

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

  def setup_gateway(%{conn: conn}) do
    gateway = insert(:gateway)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer #{gateway.access_token}")

    [conn: conn, org: gateway.org, gateway: gateway]
  end
end
