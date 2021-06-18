defmodule AcqdatApiWeb.RoleManagement.UserSettingControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Model.RoleManagement.UserSetting
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      [org: org]
    end

    test "fails if authorization header not found", context do
      %{org: org, conn: conn} = context
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}

      conn = post(conn, Routes.user_settings_path(conn, :create, org.id, 1), data)

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "fails if required params are missing", context do
      %{org: org, user: user, conn: conn} = context

      conn =
        post(
          conn,
          Routes.user_settings_path(conn, :create, org.id, user.id),
          %{}
        )

      response = conn |> json_response(400)

      assert response == %{
               "detail" =>
                 "Parameters provided to perform current action is either not valid or missing or not unique",
               "source" => %{
                 "data_settings" => ["can't be blank"],
                 "visual_settings" => ["can't be blank"],
                 "user_credentials_id" => ["can't be blank"]
               },
               "status_code" => 400,
               "title" => "Insufficient or not unique parameters"
             }
    end

    test "user setting create", context do
      %{org: org, user: user, conn: conn} = context

      user_setting = build(:user_setting)

      data = %{
        visual_settings: user_setting.visual_settings,
        data_settings: user_setting.data_settings,
        user_credentials_id: user.user_credentials_id
      }

      conn =
        post(
          conn,
          Routes.user_settings_path(conn, :create, org.id, user.user_credentials_id),
          data
        )

      response = conn |> json_response(200)
      assert Map.has_key?(response, "visual_settings")
      assert Map.has_key?(response, "data_settings")
    end
  end

  describe "update/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      [org: org]
    end

    test "fails if authorization header not found", context do
      %{org: org, conn: conn} = context
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}

      conn = post(conn, Routes.user_settings_path(conn, :create, org.id, 1), data)

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "fails if required params are missing", context do
      %{org: org, conn: conn, user: user} = context

      {:ok, user_setting} =
        build(:user_setting)
        |> Map.put(:user_credentials_id, user.user_credentials_id)
        |> Map.from_struct()
        |> UserSetting.create()

      conn =
        put(
          conn,
          Routes.user_settings_path(
            conn,
            :update,
            org.id,
            user.user_credentials_id,
            user_setting.id
          ),
          %{}
        )

      response = conn |> json_response(400)

      assert response == %{
               "detail" =>
                 "Parameters provided to perform current action is either not valid or missing or not unique",
               "source" => %{
                 "data_settings" => ["can't be blank"],
                 "visual_settings" => ["can't be blank"],
                 "user_credentials_id" => ["can't be blank"]
               },
               "status_code" => 400,
               "title" => "Insufficient or not unique parameters"
             }
    end

    test "user setting update", context do
      %{org: org, conn: conn, user: user} = context

      {:ok, user_setting} =
        build(:user_setting)
        |> Map.put(:user_credentials_id, user.user_credentials_id)
        |> Map.from_struct()
        |> UserSetting.create()

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
        },
        user_credentials_id: user.user_credentials_id
      }

      conn =
        put(
          conn,
          Routes.user_settings_path(
            conn,
            :update,
            org.id,
            user_setting.user_credentials_id,
            user_setting.id
          ),
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
