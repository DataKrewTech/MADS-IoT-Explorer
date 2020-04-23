defmodule AcqdatApiWeb.WidgetControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "index/2" do
    setup :setup_conn

    test "Widget Data", %{conn: conn} do
      test_widget = insert(:widget)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn = get(conn, Routes.widget_path(conn, :index, params))
      response = conn |> json_response(200)
      assert length(response["widgets"]) == 1
      assertion_widget = List.first(response["widgets"])
      assert assertion_widget["id"] == test_widget.id
      assert assertion_widget["widget_type_id"] == test_widget.widget_type_id
      assert assertion_widget["widget_type"]["id"] == test_widget.widget_type.id
      assert assertion_widget["widget_type"]["name"] == test_widget.widget_type.name
      assert assertion_widget["uuid"] == test_widget.uuid
    end

    test "if params are missing", %{conn: conn} do
      insert_list(3, :widget)
      conn = get(conn, Routes.widget_path(conn, :index, %{}))
      response = conn |> json_response(200)
      assert response["total_pages"] == 1
      assert length(response["widgets"]) == response["total_entries"]
    end

    test "Big page size", %{conn: conn} do
      insert_list(3, :widget)

      params = %{
        "page_size" => 100,
        "page_number" => 1
      }

      conn = get(conn, Routes.widget_path(conn, :index, params))
      response = conn |> json_response(200)
      assert response["page_number"] == params["page_number"]
      assert response["page_size"] == params["page_size"]
      assert response["total_pages"] == 1
      assert length(response["widgets"]) == response["total_entries"]
    end

    test "Pagination", %{conn: conn} do
      insert_list(3, :widget)

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn = get(conn, Routes.widget_path(conn, :index, params))
      page1_response = conn |> json_response(200)
      assert page1_response["page_number"] == params["page_number"]
      assert page1_response["page_size"] == params["page_size"]
      assert page1_response["total_pages"] == 2
      assert length(page1_response["widgets"]) == page1_response["page_size"]

      params = Map.put(params, "page_number", 2)
      conn = get(conn, Routes.widget_path(conn, :index, params))
      page2_response = conn |> json_response(200)

      assert page2_response["page_number"] == params["page_number"]
      assert page2_response["page_size"] == params["page_size"]
      assert page2_response["total_pages"] == 2
      assert length(page2_response["widgets"]) == 1
    end

    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn = get(conn, Routes.widget_path(conn, :index, params))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

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
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  # describe "search_widgets/2" do
  #   setup :setup_conn

  #   test "fails if authorization header not found", %{conn: conn} do
  #     bad_access_token = "avcbd123489u"

  #     conn =
  #       conn
  #       |> put_req_header("authorization", "Bearer #{bad_access_token}")

  #     conn =
  #       get(conn, Routes.widget_path(conn, :search_widget, %{
  #         "label" => "line"
  #       }))

  #     result = conn |> json_response(403)
  #     assert result == %{"errors" => %{"message" => "Unauthorized"}}
  #   end

  # test "search with valid params", %{conn: conn} do
  #   conn =
  #     get(conn, Routes.widget_path(conn, :search_widget, %{
  #       "label" => "line"
  #     }))

  #   result = conn |> json_response(200)   
  #   assert result = %{
  #            "widgets" => [
  #             "category" => [
  #               "chart",
  #               "line"
  #           ],
  #           "id" => null,
  #           "label" =>  "line",
  #           "properties" =>  {},
  #           "uuid" => "7a9dc8dc854e11ea964f98460aa1c6de"
  #            ]
  #          }
  # end

  #   test "search with no hits ", %{conn: conn} do
  #     conn =
  #       get(conn, Routes.widget_path(conn, :search_widget, %{
  #         "label" => "Datakrew"
  #       }))

  #     result = conn |> json_response(200)

  #     assert result = %{
  #              "widgets" => []
  #            }
  #   end
  # end
end
