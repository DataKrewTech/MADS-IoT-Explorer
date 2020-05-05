defmodule AcqdatApiWeb.AppControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "index/2" do
    setup :setup_conn

    test "fails if authorization header not found", context do
      %{conn: conn} = context
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = get(conn, Routes.app_path(conn, :index, data))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "app index", %{conn: conn} do
      insert(:app)

      params = %{
        page_size: 10,
        page_number: 1
      }

      conn = get(conn, Routes.app_path(conn, :index), params)
      response = conn |> json_response(200)
      assert length(response["apps"]) == 1
    end
  end
end
