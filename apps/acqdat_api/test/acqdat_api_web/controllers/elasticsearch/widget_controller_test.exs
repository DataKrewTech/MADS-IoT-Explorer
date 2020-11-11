defmodule AcqdatApiWeb.ElasticSearch.WidgetControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Factory.ElasticSearch.Widget
  import AcqdatCore.Support.Factory

  describe "search_widgets/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn} do
      widget = insert(:widget)
      [widget: widget] = Widget.seed_widget(widget)
      :timer.sleep(1500)
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(conn, Routes.widget_path(conn, :search_widget), %{
          "label" => widget.label
        })

      result = conn |> json_response(403)
      Widget.delete_index()
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "search with valid params", %{conn: conn} do
      widget = insert(:widget)
      [widget: widget] = Widget.seed_widget(widget)
      :timer.sleep(1500)

      conn =
        get(conn, Routes.widget_path(conn, :search_widget), %{
          "label" => widget.label
        })

      result = conn |> json_response(200)

      Widget.delete_index()

      assert result == %{
               "widgets" => [
                 %{
                   "category" => widget.category,
                   "id" => widget.id,
                   "label" => widget.label,
                   "properties" => widget.properties,
                   "uuid" => widget.uuid
                 }
               ]
             }
    end

    test "search with no hits", %{conn: conn, user: user} do
      widget = insert(:widget)
      [widget: widget] = Widget.seed_widget(widget)
      :timer.sleep(1500)

      conn =
        get(conn, Routes.widget_path(conn, :search_widget), %{
          "label" => user.first_name
        })

      result = conn |> json_response(200)
      Widget.delete_index()

      assert result == %{
               "widgets" => []
             }
    end
  end

  describe "index widgets/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn} do
      [widget1, widget2, widget3] = Widget.seed_multiple_widget()
      :timer.sleep(1500)
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(conn, Routes.widget_path(conn, :index), %{
          "from" => 0,
          "page_size" => 1
        })

      result = conn |> json_response(403)
      Widget.delete_index()
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "index with valid params and multiple entries", %{conn: conn} do
      [widget1, widget2, widget3] = Widget.seed_multiple_widget()
      :timer.sleep(1500)

      conn =
        get(conn, Routes.widget_path(conn, :index), %{
          "from" => 0,
          "page_size" => 3
        })

      %{"widgets" => widgets} = conn |> json_response(200)

      Widget.delete_index()
      assert length(widgets) == 3
      [rwidget1, rwidget2, rwidget3] = widgets
      assert rwidget1["id"] == widget1.id
      assert rwidget2["id"] == widget2.id
      assert rwidget3["id"] == widget3.id
    end
  end

  describe "widget type dependency/2" do
    setup :setup_conn

    test "if widget type is deleted", %{conn: conn} do
      [widget1, widget2, widget3] = Widget.seed_multiple_widget()
      :timer.sleep(1500)
      require IEx
      IEx.pry()
      conn = delete(conn, Routes.widget_type_path(conn, :delete, widget1.widget_type_id))

      conn =
        get(conn, Routes.widget_path(conn, :index), %{
          "from" => 0,
          "page_size" => 100
        })

      %{"widgets" => widgets} = conn |> json_response(200)
      Widget.delete_index()
      assert length(widgets) == 2
    end
  end
end
