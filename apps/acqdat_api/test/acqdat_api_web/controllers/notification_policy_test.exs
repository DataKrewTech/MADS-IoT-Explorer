defmodule AcqdatApiWeb.NotificationPolicyTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Model.User
  import AcqdatCore.Support.Factory
  
  describe "index/2" do
    setup :setup_conn
    
    test "fails if invalid token in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = get(conn, Routes.notification_policy_path(conn, :index))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "listing policies", %{conn: conn} do
      conn = get(conn, Routes.notification_policy_path(conn, :index))
      result = conn |> json_response(200)
      assert Map.has_key?(result, "policy_list")
      %{"policy_list" => [policy_list]} = result
      assert Map.has_key?(policy_list, "policy_name")
      assert Map.has_key?(policy_list, "preferences_name")
      assert Map.has_key?(policy_list, "rule_data")
      assert Map.has_key?(policy_list, "rule_name")
    end
  end
  
  def setup_conn(%{conn: conn}) do
    params =
      build(:user)
      |> Map.put(:password, "stark1234")
      |> Map.put(:password_confirmation, "stark1234")
      |> Map.from_struct()

    {:ok, user} = User.create(params)
    sign_in_data = %{email: user.email, password: params.password}
    conn = post(conn, Routes.auth_path(conn, :sign_in), sign_in_data)
    result = conn |> json_response(200)
    access_token = result["access_token"]

    conn =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer #{access_token}")

    [conn: conn]
  end
end