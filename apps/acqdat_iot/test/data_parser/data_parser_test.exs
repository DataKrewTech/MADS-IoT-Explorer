defmodule AcqdatIotWeb.DataParser do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  use AcqdatIotWeb.ConnCase
  alias AcqdatApiWeb.Guardian
  alias AcqdatIot.DataParser
  alias AcqdatCore.Schema.EntityManagement.SensorsData
  alias AcqdatCore.Schema.IotManager.Gateway
  alias AcqdatCore.Schema.IotManager.GatewayDataDump, as: GDD
  alias AcqdatCore.Model.IotManager.GatewayDataDump
  alias AcqdatCore.Repo
  import Plug.Conn
  import AcqdatCore.Support.Factory

  @access_time_hours 5

  describe "data parser/1" do
    setup :setup_gateway

    test "data parser with object type", %{
      conn: conn,
      gateway: gateway,
      params1: params1,
      sensors_data: sensors_data
    } do
      {:ok, data_dump} = GatewayDataDump.create(params1)
      extract_data()
      [data] = Repo.all(SensorsData)

      %{x_axis: %{value: %{value: x_uuid}}, y_axis: %{value: %{value: y_uuid}}} =
        gateway.mapped_parameters[:axis_object].value

      [sensor_parameter1, sensor_parameter2] = sensors_data.parameters
      [data_parameter1, data_parameter2] = data.parameters
      %{x_axis: x_value, y_axis: y_value} = data_dump.data[:axis_object]
      assert x_uuid == sensor_parameter1.uuid
      assert y_uuid == sensor_parameter2.uuid
      assert x_uuid == data_parameter1.uuid
      assert y_uuid == data_parameter2.uuid
      assert String.to_integer(data_parameter1.value) == x_value
      assert String.to_integer(data_parameter2.value) == y_value
    end

    test "data parser with list type", %{
      conn: conn,
      gateway: gateway,
      params2: params2,
      sensors_data: sensors_data
    } do
      {:ok, data_dump} = GatewayDataDump.create(params2)
      extract_data()
      [data] = Repo.all(SensorsData)
      [%{value: uuid}] = gateway.mapped_parameters[:axis].value
      [sensor_parameter1, sensor_parameter2] = sensors_data.parameters
      [data_parameter1, data_parameter2] = data.parameters
      [value | _] = data_dump.data[:axis]
      assert uuid == sensor_parameter1.uuid
      assert uuid != sensor_parameter2.uuid
      assert uuid == data_parameter1.uuid
      assert uuid != data_parameter2.uuid
      assert String.to_integer(data_parameter1.value) == value
      assert String.to_integer(data_parameter2.value) != value
    end

    test "data parser with single value type", %{
      conn: conn,
      gateway: gateway,
      params3: params3,
      sensors_data: sensors_data
    } do
      {:ok, data_dump} = GatewayDataDump.create(params3)
      extract_data()
      [data] = Repo.all(SensorsData)
      uuid = gateway.mapped_parameters[:x_axis].value
      [sensor_parameter1, sensor_parameter2] = sensors_data.parameters
      [data_parameter1, data_parameter2] = data.parameters
      value = data_dump.data[:x_axis]
      assert uuid != sensor_parameter1.uuid
      assert uuid == sensor_parameter2.uuid
      assert uuid != data_parameter1.uuid
      assert uuid == data_parameter2.uuid
      assert String.to_integer(data_parameter1.value) != value
      assert String.to_integer(data_parameter2.value) == value
    end
  end

  def setup_gateway(%{conn: conn}) do
    asset = insert(:asset)
    sensor = insert(:sensor)
    org = insert(:organisation)
    project = insert(:project)
    sensors_data = insert_sensors_data(sensor, org)
    gateway = insert_gateway(org, project, sensor, asset, sensors_data.parameters)
    [params1: params1, params2: params2, params3: params3] = setup_params(gateway)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer #{gateway.access_token}")

    [
      conn: conn,
      gateway: gateway,
      params1: params1,
      params2: params2,
      params3: params3,
      sensors_data: sensors_data
    ]
  end

  def insert_gateway(org, project, sensor, asset, [param1, param2]) do
    params = %{
      uuid: UUID.uuid1(:hex),
      name: "Gateway",
      access_token:
        "1yJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhY3FkYXRfYXBpIiwiZXhwIjoxNTkyNjUxMjAwLCJpYXQiOjE1OTI2MzMyMDAsImlzcyI6ImFjcWRhdF9hcGkiLCJqdGkiOiJmYmY2NjliZi00YzI4LTQ1N2MtODFiOS0z",
      slug: "hbGciOiJIUzUxMiIsInR5cCI6I",
      org_id: org.id,
      project_id: project.id,
      parent_id: asset.id,
      parent_type: "Asset",
      channel: "Gateway Channel",
      mapped_parameters: %{
        x_axis: %{
          type: "value",
          entity: "sensor",
          entity_id: sensor.id,
          value: param2.uuid
        },
        axis: %{
          type: "list",
          value: [
            %{
              type: "value",
              entity: "sensor",
              entity_id: sensor.id,
              value: param1.uuid
            }
          ]
        },
        axis_object: %{
          type: "object",
          value: %{
            x_axis: %{
              type: "object",
              value: %{
                type: "value",
                entity: "sensor",
                entity_id: sensor.id,
                value: param1.uuid
              }
            },
            y_axis: %{
              type: "object",
              value: %{
                type: "value",
                entity: "sensor",
                entity_id: sensor.id,
                value: param2.uuid
              }
            }
          }
        }
      },
      streaming_data: [],
      static_data: []
    }

    changeset = Gateway.changeset(%Gateway{}, params)
    Repo.insert!(changeset)
  end

  def setup_params(gateway) do
    params1 = %{
      gateway_id: gateway.id,
      org_id: gateway.org_id,
      project_id: gateway.project_id,
      data: %{
        axis_object: %{
          x_axis: 20,
          y_axis: 21
        }
      },
      inserted_timestamp: "2019-08-07T10:10:01Z"
    }

    params2 = %{
      gateway_id: gateway.id,
      org_id: gateway.org_id,
      project_id: gateway.project_id,
      data: %{
        axis: [12, 13, 14]
      },
      inserted_timestamp: "2019-08-07T10:10:01Z"
    }

    params3 = %{
      gateway_id: gateway.id,
      org_id: gateway.org_id,
      project_id: gateway.project_id,
      data: %{
        x_axis: 12
      },
      inserted_timestamp: "2019-08-07T10:10:01Z"
    }

    [params1: params1, params2: params2, params3: params3]
  end

  def insert_sensors_data(sensor, org) do
    params = %{
      sensor_id: sensor.id,
      org_id: org.id,
      inserted_timestamp: DateTime.truncate(DateTime.utc_now(), :second),
      parameters: [
        %{
          name: "Sensors Data 1",
          data_type: "integer",
          value: "-1"
        },
        %{
          name: "Sensors Data 2",
          data_type: "float",
          value: "-1"
        }
      ]
    }

    sensors_data_changeset = SensorsData.changeset(%SensorsData{}, params)
    Repo.insert!(sensors_data_changeset)
  end

  def extract_data() do
    data_dumps = Repo.all(GDD)
    Enum.each(data_dumps, fn data -> DataParser.start_parsing(data) end)
  end
end