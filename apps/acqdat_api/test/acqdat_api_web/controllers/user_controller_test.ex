defmodule AcqdatApiWeb.UserControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "show/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn} do
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = get(conn, Routes.user_path(conn, :show, 1))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "user with invalid organisation id", %{conn: conn} do
      insert(:user)

      conn = get(conn, Routes.user_path(conn, :show, -1))
      result = conn |> json_response(404)
      assert result == %{"errors" => %{"message" => "Resource Not Found"}}
    end

    test "user with valid id", %{conn: conn} do
      user = insert(:user)

      params = %{
        id: user.id
      }

      conn = get(conn, Routes.user_path(conn, :show, params.id))
      result = conn |> json_response(200)

      assert result["id"] == user.id
    end
  end
end
