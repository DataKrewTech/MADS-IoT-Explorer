defmodule AcqdatApiWeb.AuthControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Model.User
  import AcqdatCore.Support.Factory

  describe "sign_in/2" do
    setup :setup_user_with_conn

    test "sign in and returns token", context do
      %{conn: conn, user: user, user_params: params} = context
      data = %{email: user.email, password: params.password}
      conn = post(conn, Routes.auth_path(conn, :sign_in), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "access_token")
      assert Map.has_key?(response, "refresh_token")
      assert Map.has_key?(response, "user_id")
    end

    test "error if credentials not verified", context do
      %{conn: conn, user: user} = context
      data = %{email: user.email, password: "acb124"}
      conn = post(conn, Routes.auth_path(conn, :sign_in), data)
      response = conn |> json_response(200)
      assert response == %{"errors" => %{"message" => "unauthenticated"}}
    end

    test "error if missing params", context do
      %{conn: conn, user: user} = context
      data = %{email: user.email}
      conn = post(conn, Routes.auth_path(conn, :sign_in), data)
      response = conn |> json_response(400)
      assert response == %{
        "errors" => %{"message" => %{"password" => ["can't be blank"]}}
      }
    end
  end

  describe "refresh_token/2" do
    setup :setup_user_with_conn
    setup %{conn: conn, user: user, user_params: params} do
      data = %{email: user.email, password: params.password}
      conn = post(conn, Routes.auth_path(conn, :sign_in), data)
      result = conn |> json_response(200)

      [access_token: result["access_token"],
        refresh_token: result["refresh_token"]]
    end

    test "returns a new access token", context do
      %{access_token: access_token, refresh_token: refresh_token} = context
      params = %{access_token: access_token, refresh_token: refresh_token}
      conn = post(conn, Routes.auth_path(conn, :refresh_token), params)
    end
  end

  def setup_user_with_conn(_context) do
    params = build(:user)
      |> Map.put(:password, "stark1234")
      |> Map.put(:password_confirmation, "stark1234")
      |> Map.from_struct()

    {:ok, user} = User.create(params)

    conn =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")
    [user: user, user_params: params, conn: conn]
  end

end
