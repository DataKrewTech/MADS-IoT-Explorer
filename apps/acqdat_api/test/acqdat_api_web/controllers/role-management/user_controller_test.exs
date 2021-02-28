defmodule AcqdatApiWeb.RoleManagement.UserControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Schema.RoleManagement.User
  alias AcqdatCore.Model.RoleManagement.UserGroup
  alias AcqdatCore.Model.RoleManagement.GroupUser
  alias AcqdatCore.Model.RoleManagement.User, as: UModel
  alias AcqdatCore.Repo
  import AcqdatCore.Support.Factory

  describe "show/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn, org: org} do
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = get(conn, Routes.user_path(conn, :show, org.id, 1))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "user with invalid organisation id", %{conn: conn, user: _user, org: org} do
      conn = get(conn, Routes.user_path(conn, :show, org.id, -1))
      result = conn |> json_response(404)
      assert result == %{"errors" => %{"message" => "Resource Not Found"}}
    end

    test "user with valid id", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user.org_id, user.id))
      result = conn |> json_response(200)

      assert result["id"] == user.id
    end
  end

  describe "delete/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn, org: org} do
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn = delete(conn, Routes.user_path(conn, :delete, org.id, 1))
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "user with invalid organisation id", %{conn: conn, user: _user, org: org} do
      conn = delete(conn, Routes.user_path(conn, :delete, -1, 1))
      result = conn |> json_response(404)
      assert result == %{"errors" => %{"message" => "Resource Not Found"}}
    end

    test "user with valid id", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user.org_id, user.id))
      result = conn |> json_response(200)
      result = Repo.get(User, user.id)
      assert result.is_deleted == true
    end
  end

  describe "assets/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      project = insert(:project, org: org)
      asset = insert(:asset, org: org, project: project)
      user = insert(:user)

      [user: user, asset: asset, org: org, project: project]
    end

    test "fails if authorization header not found", context do
      %{user: user, conn: conn, org: org} = context

      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = put(conn, Routes.user_assets_path(conn, :assets, org.id, user.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if assets params are not present", context do
      %{user: user, conn: conn, org: org} = context

      params = %{}

      conn = put(conn, Routes.user_assets_path(conn, :assets, org.id, user.id), params)
      response = conn |> json_response(400)
      assert response == %{"errors" => %{"message" => %{"assets" => ["can't be blank"]}}}
    end

    test "update user's assets", context do
      %{user: user, asset: asset, conn: conn, org: org} = context

      params = %{
        assets: [
          %{
            id: asset.id,
            name: asset.name
          }
        ]
      }

      conn = put(conn, Routes.user_assets_path(conn, :assets, org.id, user.id), params)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "assets")
    end
  end

  describe "update user groups and policies/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      user = insert(:user, org: org)
      policies = insert_list(3, :policy)
      [policy1, policy2, policy3] = policies
      user_policy = insert(:user_policy, user: user, policy: policy3)

      [user: user, policies: [policy1, policy2, policy3], org: org, user_policy: user_policy]
    end

    @tag timeout: :infinity

    test "adding user's to another groups", context do
      %{user: user, policies: policies, conn: conn, org: org, user_policy: user_policy} = context
      [policy1, policy2, policy3] = policies
      policy_ids = extract_policy_ids(policies)
      user_ids = [user.id]

      params = %{
        name: "User Group Testing 1",
        org_id: org.id,
        user_ids: user_ids,
        policy_ids: [policy1.id, policy2.id]
      }

      {:ok, user_group1} = UserGroup.create(params)
      new_policy = insert(:policy)
      user1 = insert(:user, org: org)
      user_ids = [user1.id]

      params = %{
        name: "User Group Testing 2",
        org_id: org.id,
        user_ids: user_ids,
        policy_ids: [new_policy.id]
      }

      {:ok, user_group2} = UserGroup.create(params)
      policy3_temp = policy3 |> Map.from_struct() |> Map.drop([:__meta__, :id])

      params = %{
        group_ids: [user_group1.id, user_group2.id],
        policies: [policy3_temp]
      }

      conn = put(conn, Routes.user_path(conn, :update, org.id, user.id), params)
      response = conn |> json_response(200)
      user = Repo.get(User, user.id) |> Repo.preload(:user_group)
      user_group_ids = extract_group_ids(user.user_group)
      assert user_group_ids == [user_group1.id, user_group2.id]
    end

    test "adding user's to another policy", context do
      %{user: user, policies: policies, conn: conn, org: org, user_policy: user_policy} = context
      [policy1, policy2, policy3] = policies
      policy_ids = extract_policy_ids(policies)
      user_ids = [user.id]

      params = %{
        name: "User Group Testing 1",
        org_id: org.id,
        user_ids: user_ids,
        policy_ids: [policy1.id, policy2.id]
      }

      {:ok, user_group1} = UserGroup.create(params)
      new_policy = insert(:policy)
      user1 = insert(:user, org: org)
      user_ids = [user1.id]

      params = %{
        name: "User Group Testing 2",
        org_id: org.id,
        user_ids: user_ids,
        policy_ids: [new_policy.id]
      }

      {:ok, user_group2} = UserGroup.create(params)
      new_policy1 = insert(:policy)
      policy3_temp = policy3 |> Map.from_struct() |> Map.drop([:__meta__, :id])
      new_policy_temp = new_policy1 |> Map.from_struct() |> Map.drop([:__meta__, :id])

      params = %{
        group_ids: [user_group1.id, user_group2.id],
        policies: [policy3_temp, new_policy_temp]
      }

      conn = put(conn, Routes.user_path(conn, :update, org.id, user.id), params)
      response = conn |> json_response(200)
      user = Repo.get(User, user.id) |> Repo.preload(:policies)
      policy_ids = extract_policy_id_of_user(user.policies)
      assert policy_ids == [policy3.id, new_policy1.id]
    end

    test "adding user's to another group and policy", context do
      %{user: user, policies: policies, conn: conn, org: org, user_policy: user_policy} = context
      [policy1, policy2, policy3] = policies
      policy_ids = extract_policy_ids(policies)
      user_ids = [user.id]

      params = %{
        name: "User Group Testing 1",
        org_id: org.id,
        user_ids: user_ids,
        policy_ids: [policy1.id, policy2.id]
      }

      {:ok, user_group1} = UserGroup.create(params)
      new_policy = insert(:policy)
      user1 = insert(:user, org: org)
      user_ids = [user1.id]

      params = %{
        name: "User Group Testing 2",
        org_id: org.id,
        user_ids: user_ids,
        policy_ids: [new_policy.id]
      }

      {:ok, user_group2} = UserGroup.create(params)
      new_policy1 = insert(:policy)
      policy3_temp = policy3 |> Map.from_struct() |> Map.drop([:__meta__, :id])
      new_policy_temp = new_policy1 |> Map.from_struct() |> Map.drop([:__meta__, :id])

      params = %{
        group_ids: [user_group1.id, user_group2.id],
        policies: [policy3_temp, new_policy_temp]
      }

      conn = put(conn, Routes.user_path(conn, :update, org.id, user.id), params)
      response = conn |> json_response(200)
      user = Repo.get(User, user.id) |> Repo.preload([:policies, :user_group])
      policy_ids = extract_policy_id_of_user(user.policies)
      user_group_ids = extract_group_ids(user.user_group)
      assert user_group_ids == [user_group1.id, user_group2.id]
      assert policy_ids == [policy3.id, new_policy1.id]
    end
  end

  describe "apps/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      app = insert(:app)
      user = insert(:user)

      [user: user, app: app, org: org]
    end

    test "fails if authorization header not found", context do
      %{user: user, conn: conn, org: org} = context

      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = put(conn, Routes.user_apps_path(conn, :apps, org.id, user.id), data)
      result = conn |> json_response(403)
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "fails if assets params are not present", context do
      %{user: user, conn: conn, org: org} = context

      params = %{}

      conn = put(conn, Routes.user_apps_path(conn, :apps, org.id, user.id), params)
      response = conn |> json_response(400)
      assert response == %{"errors" => %{"message" => %{"apps" => ["can't be blank"]}}}
    end

    test "update user's apps", context do
      %{user: user, app: app, conn: conn, org: org} = context

      params = %{
        apps: [
          %{
            id: app.id,
            name: app.name
          }
        ]
      }

      conn = put(conn, Routes.user_apps_path(conn, :apps, org.id, user.id), params)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "apps")
    end
  end

  describe "create/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      invitation = insert(:invitation)
      [org: org, invitation: invitation]
    end

    test "fails if invitation-token header not found", context do
      %{org: org, conn: conn} = context

      bad_invitation_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("invitation-token", bad_invitation_token)

      data = %{
        user: %{
          password: "test123@!%$",
          password_confirmation: "test123@!%$",
          first_name: "Demo Name"
        }
      }

      conn = post(conn, Routes.user_path(conn, :create, org.id), data)
      result = conn |> json_response(400)

      assert result["errors"] == %{"message" => %{"error" => "Invitation is Invalid"}}
    end

    test "user created when valid token is provided", context do
      %{org: org, conn: conn} = context
      salt = "test user_salt"
      token = Phoenix.Token.sign(AcqdatApiWeb.Endpoint, salt, %{email: "test@test.com"})
      invitation = insert(:invitation, token: token, salt: salt, email: "test@test.com")

      assert token == invitation.token
      assert salt == invitation.salt

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

      conn = post(conn, Routes.user_path(conn, :create, org.id), data)

      response = conn |> json_response(200)
      assert Map.has_key?(response, "is_invited")
      assert response["is_invited"]
      assert response["first_name"] == "Demo Name"
    end

    test "user creation fails in case of invalid token", context do
      %{org: org, invitation: invitation, conn: conn} = context

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

      conn = post(conn, Routes.user_path(conn, :create, org.id), data)

      response = conn |> json_response(400)
      assert response["errors"] == %{"message" => %{"error" => "Invalid Invitation Token"}}
    end

    test "existing user created when valid token is provided", context do
      %{org: org, conn: conn} = context
      salt = "test user_salt"

      user = insert(:user)
      token = Phoenix.Token.sign(AcqdatApiWeb.Endpoint, salt, %{email: user.email})
      invitation = insert(:invitation, token: token, salt: salt, email: user.email)

      assert token == invitation.token
      assert salt == invitation.salt

      {:ok, result} = UModel.delete(user)
      result = Repo.get(User, user.id)

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

      assert result.is_deleted == true
      conn = post(conn, Routes.user_path(conn, :create, org.id), data)
      response = conn |> json_response(200)
      result = Repo.get(User, response["id"])
      assert result.is_deleted == false
    end
  end

  defp extract_policy_ids(policies) do
    Enum.reduce(policies, [], fn policy, acc ->
      acc ++ [policy.id]
    end)
  end

  defp extract_group_ids(user_group) do
    Enum.reduce(user_group, [], fn group, acc ->
      acc ++ [group.user_group_id]
    end)
  end

  defp extract_policy_id_of_user(policies) do
    Enum.reduce(policies, [], fn policy, acc ->
      acc ++ [policy.policy_id]
    end)
  end
end
