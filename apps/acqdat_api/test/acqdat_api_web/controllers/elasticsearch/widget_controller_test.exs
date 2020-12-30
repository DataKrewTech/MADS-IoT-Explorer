defmodule AcqdatApiWeb.ElasticSearch.WidgetControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Factory.ElasticSearch.Widget
  import AcqdatCore.Support.Factory

  describe "search_widgets/2" do
    setup :setup_conn

    setup do
      widget = insert(:widget)
      [widget: widget] = Widget.seed_widget(widget)
      :timer.sleep(2500)

      on_exit(fn ->
        Widget.delete_index()
      end)

      [widget: widget]
    end

    test "fails if authorization header not found", %{conn: conn, widget: widget} do
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(conn, Routes.widget_path(conn, :search_widget), %{
          "label" => widget.label
        })

      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "search with valid params", %{conn: conn, widget: widget} do
      conn =
        get(conn, Routes.widget_path(conn, :search_widget), %{
          "label" => widget.label
        })

      result = conn |> json_response(200)

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
      conn =
        get(conn, Routes.widget_path(conn, :search_widget), %{
          "label" => user.first_name
        })

      result = conn |> json_response(200)

      assert result == %{
               "widgets" => []
             }
    end
  end

  describe "index widgets/2" do
    setup :setup_conn

    setup do
      [widget1, widget2, widget3] = Widget.seed_multiple_widget(3)
      :timer.sleep(2500)

      on_exit(fn ->
        Widget.delete_index()
      end)

      [widget1: widget1, widget2: widget2, widget3: widget3]
    end

    test "fails if authorization header not found", %{conn: conn} do
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
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "index with valid params and multiple entries", %{
      conn: conn,
      widget1: widget1,
      widget2: widget2,
      widget3: widget3
    } do
      conn =
        get(conn, Routes.widget_path(conn, :index), %{
          "from" => 0,
          "page_size" => 3
        })

      %{"widgets" => widgets} = conn |> json_response(200)

      assert length(widgets) == 3
      [rwidget1, rwidget2, rwidget3] = widgets
      assert rwidget1["id"] == widget1.id
      assert rwidget2["id"] == widget2.id
      assert rwidget3["id"] == widget3.id
    end
  end

  describe "widget type dependency/2" do
    setup :setup_conn

    setup do
      [widget1, widget2, widget3] = Widget.seed_multiple_widget(3)
      :timer.sleep(2500)

      on_exit(fn ->
        Widget.delete_index()
      end)

      [widget1: widget1, widget2: widget2, widget3: widget3]
    end

    test "if widget type is deleted", %{conn: conn, widget1: widget1} do
      conn = delete(conn, Routes.widget_type_path(conn, :delete, widget1.widget_type_id))

      conn =
        get(conn, Routes.widget_path(conn, :index), %{
          "from" => 0,
          "page_size" => 100
        })

      %{"widgets" => widgets} = conn |> json_response(200)
      assert length(widgets) == 2
    end
  end

  describe "update and delete widgets/2" do
    setup :setup_conn

    setup do
      widget = insert(:widget)
      [widget: widget] = Widget.seed_widget(widget)
      :timer.sleep(2500)

      on_exit(fn ->
        Widget.delete_index()
      end)

      [widget: widget]
    end

    test "if widget is updated", %{conn: conn, widget: widget} do
      conn =
        put(conn, Routes.widget_path(conn, :update, widget.id), %{
          "label" => "Update Widget"
        })

      :timer.sleep(2500)

      conn =
        get(conn, Routes.widget_path(conn, :search_widget), %{
          "label" => "Update Widget"
        })

      %{
        "widgets" => [widgets]
      } = conn |> json_response(200)

      assert widgets["id"] == widget.id
      assert widgets["label"] == "Update Widget"
    end

    test "if widget is deleted", %{conn: conn, widget: widget} do
      conn =
        put(conn, Routes.widget_path(conn, :delete, widget.id), %{
          "label" => "Update Widget"
        })

      :timer.sleep(2500)

      conn =
        get(conn, Routes.widget_path(conn, :search_widget), %{
          "label" => widget.label
        })

      result = conn |> json_response(200)

      assert result == %{
               "widgets" => []
             }
    end
  end
end
