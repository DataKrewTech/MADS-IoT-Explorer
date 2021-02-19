defmodule AcqdatApiWeb.RoleManagement.UserGroupControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Schema.RoleManagement.UserGroup
  alias AcqdatCore.Model.RoleManagement.UserGroup, as: UGModel
  alias AcqdatCore.Repo
  import AcqdatCore.Support.Factory

  describe "create/2" do
    setup :setup_conn
    setup :setup_request

    test "create user group", %{conn: conn, org: org, group1: group} do
      conn = post(conn, Routes.user_group_path(conn, :create, org.id), group)
      response = conn |> json_response(200)
      assert response["name"] == group.name
      assert response["org_id"] == org.id
      assert response["policies"] -- group.actions == []
    end

    test "fails if invalid token in in authorization header", %{
      conn: conn,
      org: org,
      group1: group
    } do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        id: 3
      }

      conn = post(conn, Routes.user_group_path(conn, :create, org.id), group)
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end
  end

  describe "index/2" do
    setup :setup_conn
    setup :setup_request

    test "index user group", %{conn: conn, org: org, group1: group1, group2: group2} do
      conn = post(conn, Routes.user_group_path(conn, :create, org.id), group1)
      conn = post(conn, Routes.user_group_path(conn, :create, org.id), group2)

      params = %{
        page_number: 1,
        page_size: 20
      }

      conn = get(conn, Routes.user_group_path(conn, :index, org.id), params)
      response = conn |> json_response(200)
      [rgroup1, rgroup2] = response["groups"]
      assert rgroup1["name"] == group1.name
      assert rgroup1["org_id"] == org.id
      assert rgroup1["policies"] -- group1.actions == []
      assert rgroup2["name"] == group2.name
      assert rgroup2["org_id"] == org.id
      assert rgroup2["policies"] -- group2.actions == []
    end

    test "fails if invalid token in in authorization header", %{conn: conn, org: org} do
      bad_access_token = "qwerty1234567qwerty12"

      params = %{
        page_number: 1,
        page_size: 20
      }

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = get(conn, Routes.user_group_path(conn, :index, org.id), params)
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end
  end

  describe "update/2" do
    setup :setup_conn
    setup :setup_request

    test "update user group", %{conn: conn, org: org, group1: group1, group2: group2} do
      temp_conn = post(conn, Routes.user_group_path(conn, :create, org.id), group1)
      rgroup1 = temp_conn |> json_response(200)
      conn = put(conn, Routes.user_group_path(conn, :update, org.id, rgroup1["id"]), group2)
      response = conn |> json_response(200)
      assert response["name"] == group2.name
      assert response["org_id"] == org.id
      assert response["id"] == rgroup1["id"]
      assert response["policies"] -- Enum.uniq(group1.actions ++ group2.actions) == []
    end

    test "fails if invalid token in in authorization header", %{
      conn: conn,
      org: org,
      group1: group1,
      group2: group2
    } do
      temp_conn = post(conn, Routes.user_group_path(conn, :create, org.id), group1)
      rgroup1 = temp_conn |> json_response(200)
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = put(conn, Routes.user_group_path(conn, :update, org.id, rgroup1["id"]), group2)
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end
  end

  describe "delete/2" do
    setup :setup_conn
    setup :setup_request

    test "delete user group", %{conn: conn, org: org, group1: group1} do
      temp_conn = post(conn, Routes.user_group_path(conn, :create, org.id), group1)
      rgroup1 = temp_conn |> json_response(200)
      conn = delete(conn, Routes.user_group_path(conn, :delete, org.id, rgroup1["id"]))
      response = conn |> json_response(200)
      assert response["name"] == group1.name
      assert response["org_id"] == org.id
      assert response["id"] == rgroup1["id"]
      assert response["policies"] -- group1.actions == []
    end

    test "fails if invalid token in in authorization header", %{
      conn: conn,
      org: org,
      group1: group1,
      group2: group2
    } do
      temp_conn = post(conn, Routes.user_group_path(conn, :create, org.id), group1)
      rgroup1 = temp_conn |> json_response(200)
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = delete(conn, Routes.user_group_path(conn, :delete, org.id, rgroup1["id"]))
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end
  end

  def setup_request(_params) do
    actions1 = [
      %{"app" => "EntityManagement", "feature" => "Project", "action" => "create"},
      %{"app" => "EntityManagement", "feature" => "Sensor", "action" => "create"},
      %{"app" => "EntityManagement", "feature" => "Asset", "action" => "delete"}
    ]

    actions2 = [
      %{"app" => "EntityManagement", "feature" => "AssetType", "action" => "create"},
      %{"app" => "EntityManagement", "feature" => "Sensor", "action" => "create"},
      %{"app" => "EntityManagement", "feature" => "Asset", "action" => "delete"}
    ]

    group1 = %{
      name: "group_1",
      actions: actions1
    }

    group2 = %{
      name: "group_2",
      actions: actions2
    }

    [group1: group1, group2: group2]
  end
end
