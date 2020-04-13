defmodule AcqdatApiWeb.UserSettingControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn} do
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.user_user_setting_path(conn, :create, 1), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if required params are missing", %{conn: conn} do
      user = insert(:user)

      conn = post(conn, Routes.user_user_setting_path(conn, :create, user.id), %{})

      response = conn |> json_response(400)

      assert response == %{
               "errors" => %{
                 "message" => %{
                   "data_settings" => ["can't be blank"],
                   "visual_settings" => ["can't be blank"]
                 }
               }
             }
    end

    test "user setting create", %{conn: conn} do
      user = insert(:user)
      user_setting = build(:user_setting)

      data = %{
        visual_settings: user_setting.visual_settings,
        data_settings: user_setting.data_settings
      }

      conn = post(conn, Routes.user_user_setting_path(conn, :create, user.id), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "visual_settings")
      assert Map.has_key?(response, "data_settings")
    end
  end

  describe "update/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn} do
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.user_user_setting_path(conn, :create, 1), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if required params are missing", %{conn: conn} do
      user_setting = insert(:user_setting)

      conn =
        put(
          conn,
          Routes.user_user_setting_path(conn, :update, user_setting.user_id, user_setting.id),
          %{}
        )

      response = conn |> json_response(400)

      assert response == %{
               "errors" => %{
                 "message" => %{
                   "data_settings" => ["can't be blank"],
                   "visual_settings" => ["can't be blank"]
                 }
               }
             }
    end

    test "user setting update", %{conn: conn} do
      user_setting = insert(:user_setting)

      data = %{
        visual_settings: %{
          recently_visited_apps: ["data_cruncher1", "support", "settings", "updated_dashboard"],
          id: user_setting.visual_settings.id,
          taskbar_pos: "bottom"
        },
        data_settings: %{
          id: user_setting.data_settings.id,
          latitude: 11.222,
          longitude: 23.23
        }
      }

      conn =
        put(
          conn,
          Routes.user_user_setting_path(conn, :update, user_setting.user_id, user_setting.id),
          data
        )

      response = conn |> json_response(200)
      assert Map.has_key?(response, "visual_settings")
      assert Map.has_key?(response, "data_settings")
      assert response["data_settings"]["latitude"] == 11.222
      assert response["data_settings"]["longitude"] == 23.23
      assert response["visual_settings"]["taskbar_pos"] == "bottom"
    end
  end
end
