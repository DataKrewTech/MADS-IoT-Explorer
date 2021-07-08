defmodule AcqdatApiWeb.RoleManagement.InvitationControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Repo

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

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "invitation create", context do
      %{org: org, conn: conn} = context

      user_cred = insert(:user_credentials)
      role = insert(:role)

      data = %{invitation: %{email: user_cred.email, role_id: role.id}}

      conn = post(conn, Routes.invitation_path(conn, :create, org.id), data)

      response = conn |> json_response(200)

      assert response == %{
               "status" =>
                 "Sent invitation to the user successfully, they will receive email after sometime!"
             }
    end

    test "re-invitation email will be sent when user re-invites the same user", context do
      %{conn: conn} = context

      invitation = insert(:invitation)

      data = %{
        invitation: %{email: invitation.email, role_id: invitation.id, org_id: invitation.org_id}
      }

      conn = post(conn, Routes.invitation_path(conn, :create, invitation.org_id), data)

      response = conn |> json_response(200)

      assert response == %{
               "status" =>
                 "Sent Reinvitation to the user successfully, they will receive email after sometime!"
             }
    end

    test "creation of invitation fails if the user with email exists in specified organisation",
         context do
      %{conn: conn} = context

      user = insert(:user) |> Repo.preload([:user_credentials])

      role = insert(:role)

      data = %{
        invitation: %{
          email: user.user_credentials.email,
          role_id: role.id,
          org_id: user.org_id,
          assets: [],
          apps: [],
          group_ids: [],
          policies: []
        }
      }

      conn = post(conn, Routes.invitation_path(conn, :create, user.org_id), data)

      response = conn |> json_response(400)

      assert response == %{
               "detail" =>
                 "Parameters provided to perform current action is either not valid or missing or not unique",
               "source" => %{
                 "email" => ["user with this email already exists for the specified organisation"]
               },
               "status_code" => 400,
               "title" => "Insufficient or not unique parameters"
             }
    end
  end

  describe "index/2" do
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
      conn = post(conn, Routes.invitation_path(conn, :index, org.id), data)
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "invitation index", %{conn: conn} do
      invitation = insert(:invitation)

      params = %{
        page_size: 10,
        page_number: 1
      }

      conn = get(conn, Routes.invitation_path(conn, :index, invitation.org_id), params)
      response = conn |> json_response(200)
      assert response["total_entries"] == 1
    end
  end

  describe "delete/2" do
    setup :setup_conn

    setup do
      invitation = insert(:invitation)

      [invitation: invitation]
    end

    test "invitation delete", context do
      %{invitation: invitation, conn: conn} = context

      conn =
        delete(conn, Routes.invitation_path(conn, :delete, invitation.org_id, invitation.id), %{})

      response = conn |> json_response(200)
      assert response["status"] == "Invitation deleted successfully!"
    end

    test "fails if invalid token in authorization header", context do
      %{invitation: invitation, conn: conn} = context
      bad_access_token = "qwerty1234567qwerty"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        delete(conn, Routes.invitation_path(conn, :delete, invitation.org_id, invitation.id), %{})

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

    setup do
      invitation = insert(:invitation)

      [invitation: invitation]
    end

    test "invitation token updated", context do
      %{invitation: invitation, conn: conn} = context

      conn =
        put(conn, Routes.invitation_path(conn, :update, invitation.org_id, invitation.id), %{
          "invitation" => %{"group_ids" => [], "policies" => []}
        })

      response = conn |> json_response(200)

      assert response["status"] ==
               "Sent Reinvitation to the user successfully, they will receive email after sometime!"
    end

    test "re-invitation email will be sent when user re-invites the same user",
         context do
      %{invitation: invitation, conn: conn} = context

      data = %{
        user: %{
          password: "test123@!%$",
          password_confirmation: "test123@!%$",
          first_name: "Demo Name"
        }
      }

      conn =
        conn
        |> put_req_header("invitation-token", invitation.token)

      post(conn, Routes.user_path(conn, :create, invitation.org_id), data)

      conn =
        put(conn, Routes.invitation_path(conn, :update, invitation.org_id, invitation.id), %{
          "invitation" => %{"group_ids" => [], "policies" => []}
        })

      response = conn |> json_response(200)

      assert response["status"] ==
               "Sent Reinvitation to the user successfully, they will receive email after sometime!"
    end

    test "fails if invalid token in authorization header", context do
      %{invitation: invitation, conn: conn} = context
      bad_access_token = "qwerty1234567qwerty"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        put(conn, Routes.invitation_path(conn, :update, invitation.org_id, invitation.id), %{})

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end
  end
end
