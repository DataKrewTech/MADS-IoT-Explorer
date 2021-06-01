defmodule AcqdatCore.Model.IotManager.GatewayTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.IotManager.Gateway
  alias AcqdatCore.Schema.IotManager.Gateway, as: GSchema
  alias AcqdatCore.Schema.EntityManagement.Sensor
  alias AcqdatCore.Repo

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

    test "not found if invalid uuid", _context do
      {:error, result} = Gateway.get(%{uuid: "x"})
      assert result == "Gateway not found"
    end
  end

  describe "update/2 " do
    setup do
      org = insert(:organisation)
      project = insert(:project, org: org)
      gateway = insert(:gateway, org: org, project: project)
      sensors = insert_list(4, :sensor, org: org, project: project)
      [sensors: sensors, gateway: gateway]
    end

    test "updating mapped parameters of a gateway to attach sensor", context do
      %{sensors: [sensor1, sensor2, sensor3, sensor4], gateway: gateway} = context
      gateway = gateway |> Repo.preload([:sensors])
      mapped_parameters = create_mapped_parameters(sensor1, sensor2)
      params = %{"mapped_parameters" => mapped_parameters}
      {:ok, gateway} = Gateway.update(gateway, params)

      sensor1 = Repo.get!(Sensor, sensor1.id)
      sensor2 = Repo.get!(Sensor, sensor2.id)
      sensor3 = Repo.get!(Sensor, sensor3.id)
      sensor4 = Repo.get!(Sensor, sensor4.id)

      assert sensor1.gateway_id == gateway.id
      assert sensor2.gateway_id == gateway.id
      assert sensor3.gateway_id !== gateway.id
      assert sensor4.gateway_id !== gateway.id
    end

    test "updating mapped parameters of a gateway to attach sensor which already has some sensor attached to it.",
         context do
      %{sensors: [sensor1, sensor2, sensor3, sensor4], gateway: gateway} = context
      gateway = gateway |> Repo.preload([:sensors])
      Gateway.associate_sensors(gateway, [sensor1.id, sensor2.id])
      gateway = Repo.get!(GSchema, gateway.id) |> Repo.preload([:sensors])
      mapped_parameters = create_mapped_parameters(sensor3, sensor4)
      params = %{"mapped_parameters" => mapped_parameters}
      {:ok, gateway} = Gateway.update(gateway, params)
      sensor1 = Repo.get!(Sensor, sensor1.id)
      sensor2 = Repo.get!(Sensor, sensor2.id)
      sensor3 = Repo.get!(Sensor, sensor3.id)
      sensor4 = Repo.get!(Sensor, sensor4.id)
      assert sensor1.gateway_id !== gateway.id
      assert sensor2.gateway_id !== gateway.id
      assert sensor3.gateway_id == gateway.id
      assert sensor4.gateway_id == gateway.id
    end

    test "updating mapped parameters of a gateway incluiding data of already attached sensor",
         context do
      %{sensors: [sensor1, sensor2, sensor3, sensor4], gateway: gateway} = context
      gateway = gateway |> Repo.preload([:sensors])
      Gateway.associate_sensors(gateway, [sensor1.id, sensor2.id])
      gateway = Repo.get!(GSchema, gateway.id) |> Repo.preload([:sensors])
      mapped_parameters = create_multiple_mapped_parameters(sensor1, sensor2, sensor3, sensor4)
      params = %{"mapped_parameters" => mapped_parameters}
      {:ok, gateway} = Gateway.update(gateway, params)
      sensor1 = Repo.get!(Sensor, sensor1.id)
      sensor2 = Repo.get!(Sensor, sensor2.id)
      sensor3 = Repo.get!(Sensor, sensor3.id)
      sensor4 = Repo.get!(Sensor, sensor4.id)
      assert sensor1.gateway_id == gateway.id
      assert sensor2.gateway_id == gateway.id
      assert sensor3.gateway_id == gateway.id
      assert sensor4.gateway_id == gateway.id
    end

    test "with nesteed parameter mapping" do

    end
  end

  describe "associate_sensors/1 " do
    setup do
      org = insert(:organisation)
      project = insert(:project, org: org)
      gateway = insert(:gateway, org: org, project: project)
      sensors = insert_list(4, :sensor, org: org, project: project)
      [sensors: sensors, gateway: gateway]
    end

    test "associates sensors, provided sensor list are unique to gateway", context do
      %{sensors: [sensor1, sensor2, sensor3, sensor4], gateway: gateway} = context
      gateway = gateway |> Repo.preload([:sensors])
      Gateway.associate_sensors(gateway, [sensor1.id, sensor2.id, sensor3.id, sensor4.id])
      sensor1 = Repo.get!(Sensor, sensor1.id)
      sensor2 = Repo.get!(Sensor, sensor2.id)
      sensor3 = Repo.get!(Sensor, sensor3.id)
      sensor4 = Repo.get!(Sensor, sensor4.id)

      assert sensor1.gateway_id == gateway.id
      assert sensor2.gateway_id == gateway.id
      assert sensor3.gateway_id == gateway.id
      assert sensor4.gateway_id == gateway.id
    end

    test "associates, while removing sensors not provided in the list", context do
      %{sensors: [sensor1, sensor2, sensor3, sensor4], gateway: gateway} = context
      sensor1 = Repo.update!(Sensor.changeset(sensor1, %{gateway_id: gateway.id}))
      gateway = gateway |> Repo.preload([:sensors])
      Gateway.associate_sensors(gateway, [sensor2.id, sensor3.id, sensor4.id])
      sensor1 = Repo.get!(Sensor, sensor1.id)
      sensor2 = Repo.get!(Sensor, sensor2.id)
      sensor3 = Repo.get!(Sensor, sensor3.id)
      sensor4 = Repo.get!(Sensor, sensor4.id)
      assert sensor1.gateway_id != gateway.id
      assert sensor2.gateway_id == gateway.id
      assert sensor3.gateway_id == gateway.id
      assert sensor4.gateway_id == gateway.id
    end

    test "associates sensors in the list including previously associated", context do
      %{sensors: [sensor1, sensor2, sensor3, sensor4], gateway: gateway} = context
      sensor1 = Repo.update!(Sensor.changeset(sensor1, %{gateway_id: gateway.id}))
      gateway = gateway |> Repo.preload([:sensors])
      Gateway.associate_sensors(gateway, [sensor1.id, sensor2.id, sensor3.id, sensor4.id])
      sensor1 = Repo.get!(Sensor, sensor1.id)
      sensor2 = Repo.get!(Sensor, sensor2.id)
      sensor3 = Repo.get!(Sensor, sensor3.id)
      sensor4 = Repo.get!(Sensor, sensor4.id)
      assert sensor1.gateway_id == gateway.id
      assert sensor2.gateway_id == gateway.id
      assert sensor3.gateway_id == gateway.id
      assert sensor4.gateway_id == gateway.id
    end
  end

  defp create_mapped_parameters(sensor1, sensor2) do
    %{
      "sensor 1 testing parameter" => %{
        "entity" => "sensor",
        "entity_id" => sensor1.id,
        "type" => "value",
        "value" => sensor1.uuid
      },
      "sensor 2 testing parameter" => %{
        "entity" => "sensor",
        "entity_id" => sensor2.id,
        "type" => "value",
        "value" => sensor2.uuid
      }
    }
  end

  defp create_multiple_mapped_parameters(sensor1, sensor2, sensor3, sensor4) do
    %{
      "sensor 1 testing parameter" => %{
        "entity" => "sensor",
        "entity_id" => sensor1.id,
        "type" => "value",
        "value" => sensor1.uuid
      },
      "sensor 2 testing parameter" => %{
        "entity" => "sensor",
        "entity_id" => sensor2.id,
        "type" => "value",
        "value" => sensor2.uuid
      },
      "sensor 3 testing parameter" => %{
        "entity" => "sensor",
        "entity_id" => sensor3.id,
        "type" => "value",
        "value" => sensor3.uuid
      },
      "sensor 4 testing parameter" => %{
        "entity" => "sensor",
        "entity_id" => sensor4.id,
        "type" => "value",
        "value" => sensor4.uuid
      }
    }
  end
end
