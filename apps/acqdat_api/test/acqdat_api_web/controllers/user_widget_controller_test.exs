defmodule AcqdatApiWeb.UserWidgetControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_conn

    test "user widget create", %{conn: conn, user: user, org: org} do
      widget = insert(:widget)

      params = %{
        widget_id: widget.id
      }

      conn = post(conn, Routes.user_widgets_path(conn, :create, org.id, user.id, params), %{})
      response = conn |> json_response(200)

      assert response == %{
               "detail" => "This is successfully added to your workspace.",
               "source" => nil,
               "status_code" => 200,
               "title" => "Widget Added"
             }
    end

    test "fails if authorization header not found", %{conn: conn, user: user, org: org} do
      bad_access_token = "qwerty1234567uiop"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.user_widgets_path(conn, :create, org.id, user.id), data)
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "fails if sent params are not unique", %{conn: conn, user: user, org: org} do
      widget = insert(:widget)

      params = %{
        widget_id: widget.id
      }

      conn = post(conn, Routes.user_widgets_path(conn, :create, org.id, user.id, params), %{})

      conn = post(conn, Routes.user_widgets_path(conn, :create, org.id, user.id, params), %{})
      response = conn |> json_response(400)

      assert response == %{
               "detail" =>
                 "Parameters provided to perform current action is either not valid or missing or not unique",
               "source" => %{"name" => ["has already been taken"]},
               "status_code" => 400,
               "title" => "Insufficient or not unique parameters"
             }
    end

    test "fails if required resource are missing", %{conn: conn, user: user, org: org} do
      params = %{
        widget_id: 2
      }

      conn = post(conn, Routes.user_widgets_path(conn, :create, org.id, user.id, params), %{})

      response = conn |> json_response(404)

      assert response == %{
               "detail" =>
                 "Either widget or user with this ID doesn't exists or you don't have access to it.",
               "source" => nil,
               "status_code" => 404,
               "title" => "Invalid entity ID"
             }
    end
  end

  describe "index/2" do
    setup :setup_conn

    test "User Widget Data", %{conn: conn, user: user, org: org} do
      widget = insert(:widget)

      params = %{
        widget_id: widget.id
      }

      conn = post(conn, Routes.user_widgets_path(conn, :create, org.id, user.id, params))

      params = %{
        user_id: user.id,
        page_size: 100,
        page_number: 1
      }

      conn = get(conn, Routes.user_widgets_path(conn, :index, org.id, user.id), params)
      response = conn |> json_response(200)
      assert length(response["user_widgets"]) == 1
      assertion_user_widget = List.first(response["user_widgets"])
      assert assertion_user_widget["widget_id"] == widget.id
      assert assertion_user_widget["user_id"] == user.id
      assert assertion_user_widget["widget"]["widget_type_id"] == widget.widget_type_id
    end

    test "fails if invalid token in authorization header", %{conn: conn, user: user, org: org} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        "user_id" => user.id,
        "page_size" => 100,
        "page_number" => 1,
        org_id: org.id
      }

      conn = get(conn, Routes.user_widgets_path(conn, :index, org.id, user.id, params), %{})
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
