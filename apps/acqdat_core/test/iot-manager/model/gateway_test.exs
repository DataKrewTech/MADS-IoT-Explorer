defmodule AcqdatCore.Model.IotManager.GatewayTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.IotManager.Gateway
  alias AcqdatCore.Schema.IotManager.BrokerCredentials

  describe "create/1" do
    setup %{} do
      org = insert(:organisation)
      project = insert(:project, org: org)
      [project: project, org: org]
    end

    test "create a gateway with http channel", context do
      %{project: project, org: org} = context

      params = %{
        name: "Gateway1",
        org_id: org.id,
        project_id: project.id,
        channel: "http",
        parent_id: project.id,
        parent_type: "Project",
        access_token: "abcd1234"
      }

      {:ok, gateway} = Gateway.create(params)
      assert gateway.name == params.name
    end

    test "returns invalid changeset if any error", context do
      %{project: project, org: org} = context

      params = %{
        name: "Gateway1",
        org_id: org.id,
        project_id: project.id,
        channel: "http",
        parent_id: project.id,
        parent_type: "Project"
      }

      {:error, changeset} = Gateway.create(params)
      assert %{access_token: ["can't be blank"]} == errors_on(changeset)
    end
  end

  describe "get_gateways/1" do
    setup do
      project = insert(:project)
      gateway1 = insert(:gateway, parent_type: "Project", parent_id: project.id)

      gateway2 =
        insert(:gateway,
          parent_type: "Project",
          parent_id: project.id,
          access_token:
            "123yJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhY3FkYXRfYXBpIiwiZXhwIjoxNTkyNjUxMjAwLCJpYXQiOjE1OTI2MzMyMDAsImlzcyI6ImFjcWRhdF9hcGkiLCJqdGkiOiJmYmY2NjliZi00YzI4LTQ1N2MtODFiOS0z"
        )

      sensor1 = insert(:sensor, gateway: gateway1)
      sensor2 = insert(:sensor, gateway: gateway2)

      [
        project: project,
        gateway1: gateway1,
        gateway2: gateway2,
        sensor1: sensor1,
        sensor2: sensor2
      ]
    end

    test "fetch hierarchy with gateways", %{
      project: project,
      gateway1: gateway1,
      gateway2: gateway2,
      sensor1: sensor1,
      sensor2: sensor2
    } do
      gateways = Gateway.get_gateways(project.id)
      [resulted_gateway1, resulted_gateway2] = gateways
      [child1] = resulted_gateway1.childs
      [child2] = resulted_gateway2.childs
      assert resulted_gateway1.name == gateway1.name
      assert resulted_gateway2.name == gateway2.name
      assert resulted_gateway1.parent.id == project.id
      assert resulted_gateway2.parent.id == project.id
      assert child1.id == sensor1.id
      assert child2.id == sensor2.id
    end
  end

  describe "get/1 " do
    setup do
      gateway = insert(:gateway)
      [gateway: gateway]
    end

    test "returns a gateway with id", context do
      %{gateway: gateway} = context
      {:ok, result} = Gateway.get(gateway.id)
      assert result.id == gateway.id
      assert result.uuid == gateway.uuid
    end

    test "returns a gateway with uuid", context do
      %{gateway: gateway} = context
      {:ok, result} = Gateway.get(%{uuid: gateway.uuid})
      assert result.id == gateway.id
      assert result.uuid == gateway.uuid
    end

    test "not found if invalid uuid", context do
      %{gateway: gateway} = context
      {:error, result} = Gateway.get(%{uuid: "x"})
      assert result == "Gateway not found"
    end
  end
end
