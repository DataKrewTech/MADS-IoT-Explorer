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
      response = conn |> json_response(401)
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

  describe "validate_token/2" do
    setup :setup_user_with_conn

    setup %{conn: conn, user: user, user_params: params} do
      data = %{email: user.email, password: params.password}
      conn = post(conn, Routes.auth_path(conn, :sign_in), data)
      result = conn |> json_response(200)

      [
        access_token: result["access_token"],
        refresh_token: result["refresh_token"]
      ]
    end

    test "returns same access token if not expired", context do
      %{access_token: access_token, refresh_token: refresh_token} = context

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{refresh_token}")

      params = %{access_token: access_token}
      conn = post(conn, Routes.auth_path(conn, :validate_token), params)
      result = conn |> json_response(200)
      assert result["access_token"] == access_token
      assert result["message"] == "Authorized"
    end

    test "returns a new access token if expired", context do
      %{refresh_token: refresh_token} = context

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{refresh_token}")

      access_token = invalid_token()
      params = %{access_token: access_token}
      conn = post(conn, Routes.auth_path(conn, :validate_token), params)

      result = conn |> json_response(200)
      assert result["access_token"] != access_token
      assert result["message"] == "Authorized"
    end

    test "returns error if refresh token in auth header not valid" do
      refresh_token = invalid_token()

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{refresh_token}")

      params = %{access_token: invalid_token()}
      conn = post(conn, Routes.auth_path(conn, :validate_token), params)

      result = conn |> json_response(400)
      assert result == %{"errors" => %{"message" => %{"__exception__" => true, "term" => 32}}}
    end

    test "returns error if access token garbage", context do
      %{refresh_token: refresh_token} = context

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{refresh_token}")

      params = %{access_token: "avcbd123489u"}
      conn = post(conn, Routes.auth_path(conn, :validate_token), params)

      result = conn |> json_response(400)

      assert %{
               "errors" => %{
                 "message" => %{
                   "__exception__" => true,
                   "message" => "argument error: [\"avcbd123489u\"]"
                 }
               }
             } == result
    end

    test "fails if authorization header not found" do
      params = %{refresh_token: "avcbd123489u"}
      conn = build_conn()
      conn = post(conn, Routes.auth_path(conn, :validate_token), params)

      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end
  end

  describe "sign_out/2" do
    setup :setup_user_with_conn

    setup %{conn: conn, user: user, user_params: params} do
      data = %{email: user.email, password: params.password}
      conn = post(conn, Routes.auth_path(conn, :sign_in), data)
      result = conn |> json_response(200)

      conn =
        build_conn()
        |> put_req_header("authorization", "Bearer #{result["refresh_token"]}")

      [
        access_token: result["access_token"],
        refresh_token: result["refresh_token"],
        conn: conn
      ]
    end

    test "sign out successfully", context do
      %{access_token: access_token, refresh_token: refresh_token, conn: conn} = context
      params = %{access_token: access_token, refresh_token: refresh_token}
      conn = post(conn, Routes.auth_path(conn, :sign_out), params)
      result = conn |> json_response(200)
      assert result == %{"status" => "Signed Out"}
    end
  end

  def setup_user_with_conn(_context) do
    params =
      build(:user)
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

  def invalid_token() do
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0N\
    TY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJS\
    MeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
  end
end
