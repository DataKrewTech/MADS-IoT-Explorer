defmodule AcqdatApiWeb.ApiAccessAuthTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.RoleManagement.{Policy, UserGroup, UserPolicy}

  describe "checkin api access to users/2" do
    setup :setup_conn
    setup :setup_groups_and_policies
    @tag timeout: :infinity

    test "checking if user is allowed to access an api", %{conn: conn, org: org, user: user} do
      project = build(:project)

      data = %{
        name: project.name,
        creator_id: user.id
      }

      conn = post(conn, Routes.project_path(conn, :create, org.id), data)
      response = conn |> json_response(200)
      assert response["name"] == project.name
      assert response["creator_id"] == user.id
      assert response["org_id"] == org.id
    end

    test "checking if user is not allowed to access an api", %{conn: conn, org: org, user: user} do
      project = insert(:project)
      sensor = insert(:sensor, project: project)

      conn = get(conn, Routes.sensor_path(conn, :show, org.id, project.id, sensor.id))
      response = conn |> json_response(401)

      assert response == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end
  end

  def setup_groups_and_policies(%{org: org, user: user}) do
    policies = [
      %{"app" => "EntityManagement", "feature" => "Project", "action" => "create"},
      %{"app" => "EntityManagement", "feature" => "Sensor", "action" => "create"},
      %{"app" => "EntityManagement", "feature" => "Asset", "action" => "delete"}
    ]

    [policy1, policy2, policy3] = Policy.extract_policies(policies)

    group1 = %{
      name: "group_1",
      org_id: org.id,
      user_ids: [user.id],
      policy_ids: [policy1, policy3]
    }

    user_group = %{
      user_id: user.id,
      policy_id: policy2
    }

    {:ok, group1} = UserGroup.create(group1)
    {:ok, user_policy} = UserPolicy.create(user_group)
    [policies: [policy1, policy2, policy3], group: group1, user_policy: [user_policy]]
  end
end
