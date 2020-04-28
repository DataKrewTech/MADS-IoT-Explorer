defmodule AcqdatApiWeb.InvitationControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
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
      conn = post(conn, Routes.invitation_path(conn, :create, org.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "invitation create", context do
      %{org: org, conn: conn} = context

      user = insert(:user)
      role = insert(:role)

      data = %{invitation: %{email: user.email, role_id: role.id}}

      conn = post(conn, Routes.invitation_path(conn, :create, org.id), data)

      response = conn |> json_response(200)

      assert response == %{
               "status" =>
                 "Send invitation to the user successfully, They will receive email after sometime!"
             }
    end
  end
end
