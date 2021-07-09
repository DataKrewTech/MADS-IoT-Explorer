defmodule AcqdatApiWeb.Widgets.WidgetControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "show/2" do
    setup :setup_conn

    test "Widget Show", %{conn: conn} do
      test_widget = insert(:widget)
      conn = get(conn, Routes.widget_path(conn, :show, test_widget.id))
      result = conn |> json_response(200)
      assert result["id"] == test_widget.id
      assert result["widget_type_id"] == test_widget.widget_type_id
      assert result["widget_type"]["id"] == test_widget.widget_type.id
      assert result["widget_type"]["name"] == test_widget.widget_type.name
      assert result["uuid"] == test_widget.uuid
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"
      test_widget = insert(:widget)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = get(conn, Routes.widget_path(conn, :show, test_widget.id))
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
