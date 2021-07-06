defmodule AcqdatCore.Model.IotManager.GatewayTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.IotManager.Gateway
  alias AcqdatApi.IotManager.Gateway, as: GatewayHelper
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

    test "with nesteed parameter mapping", context do
      %{sensors: [sensor1, sensor2, sensor3, _], gateway: gateway} = context
      mapped_parameters = create_nested_parameters(sensor1, sensor2, sensor3)
      params = %{"mapped_parameters" => mapped_parameters}
      {:ok, gateway} = Gateway.update(gateway, params)
      sensor1 = Repo.get!(Sensor, sensor1.id)
      sensor2 = Repo.get!(Sensor, sensor2.id)
      sensor3 = Repo.get!(Sensor, sensor3.id)

      assert sensor1.gateway_id == gateway.id
      assert sensor2.gateway_id == gateway.id
      assert sensor3.gateway_id == gateway.id
    end
  end

  describe "tree_mapping/1" do
    setup do
      org = insert(:organisation)
      project = insert(:project, org: org)
      gateway = insert(:gateway, org: org, project: project)
      sensors = insert_list(3, :sensor, org: org, project: project)
      [sensors: sensors, gateway: gateway]
    end

    test "parameter mapping containing nested values", context do
      %{sensors: [sensor1, sensor2, sensor3], gateway: gateway} = context
      [param1, param2] = sensor1.sensor_type.parameters
      [param3, param4] = sensor2.sensor_type.parameters
      [param5, param6] = sensor3.sensor_type.parameters
      mapped_parameters = create_nested_parameters(sensor1, sensor2, sensor3)
      tree_mapping = GatewayHelper.tree_mapping(mapped_parameters)

      resultant_map = %{
        "#{sensor1.id}.#{param1.uuid}" => "axis_object.x_axis",
        "#{sensor1.id}.#{param2.uuid}" => "axis_object.z_axis",
        "#{sensor2.id}.#{param3.uuid}" => "axis_object.z_axis",
        "#{sensor2.id}.#{param4.uuid}" => "axis_object.lambda.alpha",
        "#{sensor3.id}.#{param5.uuid}" => "axis_object.lambda.beta",
        "#{sensor3.id}.#{param6.uuid}" => "y_axis"
      }

      assert tree_mapping == resultant_map
    end
  end

  describe "mapped_parameters/1" do
    setup do
      org = insert(:organisation)
      project = insert(:project, org: org)
      gateway = insert(:gateway, org: org, project: project)
      sensors = insert_list(3, :sensor, org: org, project: project, gateway: gateway)
      [sensors: sensors, gateway: gateway]
    end

    test "parameter mapping containing nested values", context do
      %{sensors: sensors, gateway: gateway} = context
      [sensor1, sensor2, sensor3] = sensors

      data = GatewayHelper.extract_param_uuid(sensors)

      resultant_map =
        Enum.reduce(sensors, %{}, fn sensor, acc ->
          Map.put_new(acc, sensor.id, gateway.id)
        end)

      assert data == resultant_map
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

  defp create_nested_parameters(sensor1, sensor2, sensor3) do
    [param1, param2] = sensor1.sensor_type.parameters
    [param3, param4] = sensor2.sensor_type.parameters
    [param5, param6] = sensor3.sensor_type.parameters

    %{
      "axis_object" => %{
        "type" => "object",
        "value" => %{
          "x_axis" => %{
            "type" => "value",
            "entity" => "sensor",
            "entity_id" => sensor1.id,
            "value" => param1.uuid
          },
          "z_axis" => %{
            "type" => "list",
            "value" => [
              %{
                "type" => "value",
                "entity" => "sensor",
                "entity_id" => sensor1.id,
                "value" => param2.uuid
              },
              %{
                "type" => "value",
                "entity" => "sensor",
                "entity_id" => sensor2.id,
                "value" => param3.uuid
              }
            ]
          },
          "lambda" => %{
            "type" => "object",
            "value" => %{
              "alpha" => %{
                "type" => "value",
                "entity" => "sensor",
                "entity_id" => sensor2.id,
                "value" => param4.uuid
              },
              "beta" => %{
                "type" => "value",
                "entity" => "sensor",
                "entity_id" => sensor3.id,
                "value" => param5.uuid
              }
            }
          }
        }
      },
      "y_axis" => %{
        "type" => "value",
        "entity" => "sensor",
        "entity_id" => sensor3.id,
        "value" => param6.uuid
      }
    }
  end
end
