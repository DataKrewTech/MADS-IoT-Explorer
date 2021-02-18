defmodule AcqdatApiWeb.DataCruncher.ComponentsControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "index/2" do
    setup :setup_conn

    test "DataCruncher Components Listing", %{conn: conn, org: org} do
      conn = get(conn, Routes.components_path(conn, :index, org.id))
      response = conn |> json_response(200)
      assert length(response["components"]) != 0
    end

    test "fails if invalid token in authorization header", %{conn: conn, org: org} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = get(conn, Routes.components_path(conn, :index, org.id))
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
