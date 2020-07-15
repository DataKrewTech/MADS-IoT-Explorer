defmodule AcqdatCore.Schema.IotManager.GatewayTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory

  alias AcqdatCore.Schema.IotManager.Gateway

  describe "changeset/2" do
    setup do
      org = insert(:organisation)
      project = insert(:project)

      [org: org, project: project]
    end

    test "returns error changeset on empty params" do
      changeset = Gateway.changeset(%Gateway{}, %{streaming_data: [], static_data: []})

      assert %{
               name: ["can't be blank"],
               org_id: ["can't be blank"],
               project_id: ["can't be blank"],
               channel: ["can't be blank"],
               access_token: ["can't be blank"],
               parent_id: ["can't be blank"],
               parent_type: ["can't be blank"]
             } == errors_on(changeset)
    end

    test "returns error when duplicate gateway name is used", context do
      gateway = insert(:gateway)

      params = %{
        org_id: gateway.org_id,
        name: gateway.name,
        project_id: gateway.project_id,
        access_token: gateway.access_token,
        channel: gateway.channel,
        parent_id: gateway.parent_id,
        parent_type: gateway.parent_type
      }

      changeset = Gateway.changeset(%Gateway{}, params)

      {:error, changeset} = Repo.insert(changeset)

      assert %{access_token: ["has already been taken"]} == errors_on(changeset)
    end

    test "returns error when organisation is not valid", %{org: org, project: project} do
      gateway = build(:gateway)

      params = %{
        org_id: -1,
        name: gateway.name,
        project_id: project.id,
        access_token: gateway.access_token,
        channel: gateway.channel,
        parent_id: gateway.parent_id,
        parent_type: gateway.parent_type
      }

      changeset = Gateway.changeset(%Gateway{}, params)

      {:error, changeset} = Repo.insert(changeset)

      assert %{org: ["does not exist"]} == errors_on(changeset)
    end

    test "returns a valid changeset", context do
      %{org: org, project: project} = context
      gateway = build(:gateway)

      params = %{
        org_id: org.id,
        name: gateway.name,
        project_id: project.id,
        access_token: gateway.access_token,
        channel: gateway.channel,
        parent_id: gateway.parent_id,
        parent_type: gateway.parent_type
      }

      %{valid?: validity} = Gateway.changeset(%Gateway{}, params)
      assert validity
    end
  end

  describe "update_changeset/2" do
    setup do
      gateway = insert(:gateway)

      [gateway: gateway]
    end

    test "updates gateway", context do
      %{gateway: gateway} = context

      params = %{
        name: "Demo Gateway updated"
      }

      %{valid?: validity} = Gateway.changeset(gateway, params)
      assert validity
    end
  end
end
