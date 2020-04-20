defmodule AcqdatApiWeb.InvitationControllerTest do
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
      conn = post(conn, Routes.invitation_path(conn, :create), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "invitation create", %{conn: conn} do
      user = insert(:user)

      data = %{invitation: %{email: user.email}}

      conn = post(conn, Routes.invitation_path(conn, :create), data)

      response = conn |> json_response(200)

      assert response == %{
               "status" =>
                 "Send invitation to the user successfully, They will receive email after sometime!"
             }
    end
  end
end
