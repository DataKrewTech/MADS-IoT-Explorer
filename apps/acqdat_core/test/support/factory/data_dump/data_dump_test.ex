defmodule AcqdatCore.Test.Support.DataDumpTest do
  alias AcqdatCore.Model.IotManager.Gateway, as: GModel
  alias AcqdatCore.Schema.IotManager.GatewayDataDump
  alias AcqdatCore.Test.Support.DataDump
  alias AcqdatCore.Repo
  import AcqdatCore.Support.Factory

  @parameter_list1 [
    %{
      name: "Sensor Type1 params1",
      data_type: "integer",
      unit: "cm",
      uuid: UUID.uuid1(:hex)
    },
    %{
      name: "Sensor Type1 params2",
      data_type: "integer",
      unit: "m",
      uuid: UUID.uuid1(:hex)
    }
  ]

  @parameter_list2 [
    %{
      name: "Sensor Type2 params3",
      data_type: "integer",
      unit: "cm",
      uuid: UUID.uuid1(:hex)
    },
    %{
      name: "Sensor Type2 params4",
      data_type: "integer",
      unit: "m",
      uuid: UUID.uuid1(:hex)
    }
  ]

  def setup_gateway() do
    org = insert(:organisation)
    project = insert(:project, org: org)
    asset = insert(:asset, org: org, project: project)
    gateway = insert_gateway(org, project, asset)
    sensor_type1 = insert(:sensor_type, org: org, project: project, parameters: @parameter_list1)
    sensor_type2 = insert(:sensor_type, org: org, project: project, parameters: @parameter_list2)

    sensor1 =
      insert(:sensor, sensor_type: sensor_type1, org: org, project: project, gateway: gateway)

    sensor2 =
      insert(:sensor, sensor_type: sensor_type2, org: org, project: project, gateway: gateway)

    gateway = insert_mapped_parameters(gateway, sensor1, sensor2)
    [dump_iot_data(gateway), sensor1, sensor2, gateway]
  end

  def insert_multiple_datadumps(gateway) do
    data_dump1 = DataDump.dump_iot_data(gateway)
    data_dump2 = DataDump.dump_iot_data(gateway)
    data_dump3 = DataDump.dump_iot_data(gateway)
    Repo.insert_all(GatewayDataDump, [data_dump1, data_dump2, data_dump3])
  end

  def insert_gateway(org, project, asset) do
    params = %{
      uuid: UUID.uuid1(:hex),
      name: "Gateway",
      access_token: "1yJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9",
      slug: "hbGciOiJIUzUxMiIsInR5cCI6I",
      org_id: org.id,
      project_id: project.id,
      parent_id: asset.id,
      parent_type: "Asset",
      channel: "mqtt",
      streaming_data: [
        %{
          name: "Gateway Parameter 1",
          data_type: "integer",
          unit: "cm",
          uuid: UUID.uuid1(:hex)
        },
        %{
          name: "Gateway Parameter 2",
          data_type: "integer",
          unit: "m",
          uuid: UUID.uuid1(:hex)
        }
      ],
      static_data: []
    }

    {:ok, gateway} = GModel.create(params)
    gateway
  end

  def dump_iot_data(gateway) do
    %{
      gateway_uuid: gateway.uuid,
      org_uuid: gateway.org.uuid,
      project_uuid: gateway.project.uuid,
      data: %{
        "axis_object" => %{
          "x_axis" => 20,
          "z_axis" => [22, 23],
          "lambda" => %{"alpha" => 24, "beta" => 25}
        },
        "y_axis" => 21,
        # To test presence of arbitrary entries which are not mapped to anything.
        "project_id" => 1,
        "xyz" => %{},
        # timestamp so it would be picked from here
        "timestamp" => 1_596_115_581
      },
      inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
      inserted_timestamp: DateTime.truncate(DateTime.utc_now(), :second) |> DateTime.to_unix()
    }
  end

  # def extract_data() do
  #   data_dumps = Repo.all(GDD)
  #   Enum.each(data_dumps, fn data -> DataParser.start_parsing(data) end)
  # end

  def insert_mapped_parameters(gateway, sensor1, sensor2) do
    [param1, param2] = sensor1.sensor_type.parameters
    [param3, param4] = sensor2.sensor_type.parameters
    [param5, param6] = gateway.streaming_data

    mapped_parameters = %{
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
                "entity" => "gateway",
                "entity_id" => gateway.id,
                "value" => param5.uuid
              }
            }
          }
        }
      },
      "y_axis" => %{
        "type" => "value",
        "entity" => "gateway",
        "entity_id" => gateway.id,
        "value" => param6.uuid
      }
    }

    timestamp_mapping = "timestamp"

    {:ok, gateway} =
      GModel.update(gateway, %{
        mapped_parameters: mapped_parameters,
        timestamp_mapping: timestamp_mapping
      })

    gateway |> Repo.preload([:org, :project])
  end

end
