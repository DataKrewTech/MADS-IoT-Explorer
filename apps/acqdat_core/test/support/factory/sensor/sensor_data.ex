
defmodule AcqdatCore.Test.Support.SensorsData do
  import Ecto.Query
  alias AcqdatCore.Schema.EntityManagement.{Sensor, SensorsData, Organisation}
  alias AcqdatCore.Repo
  import AcqdatCore.Support.Factory

  @energy_type_parameters [
    %{name: "Voltage", data_type: "integer", uuid: UUID.uuid1(:hex)},
    %{name: "Current", data_type: "integer", uuid: UUID.uuid1(:hex)},
    %{name: "Power", data_type: "integer", uuid: UUID.uuid1(:hex)},
    %{name: "Energy", data_type: "integer", uuid: UUID.uuid1(:hex)}
  ]

  @vibration_type_parameters [
    %{name: "x_axis vel", data_type: "integer", uuid: UUID.uuid1(:hex)},
    %{name: "z_axis vel", data_type: "integer", uuid: UUID.uuid1(:hex)},
    %{name: "x_axis acc", data_type: "integer", uuid: UUID.uuid1(:hex)},
    %{name: "z_axis acc", data_type: "integer", uuid: UUID.uuid1(:hex)}
  ]

  def put_sensor_data(%{sensor_data_quantity: quantity,
      time_interval_seconds: time_interval}) do
    org = insert(:organisation)
    project = insert(:project, org: org)
    [energy_type, vibration_type] = setup_sensor_type(org, project)
    vibration_sensor = insert_sensor(vibration_type, org, project, "vibration")
    energy_sensor = insert_sensor(energy_type, org, project, "energy")

    sensor_data = add_sensor_data([energy_sensor, vibration_sensor], org, quantity, time_interval)

    [org: org, project: project, sensors: [vibration_sensor, energy_sensor],
      sensor_data: sensor_data]
  end

  defp setup_sensor_type(org, project) do
    energy_type = insert(:sensor_type, name: "energy_sensor_type", org: org,
      project: project, parameters: @energy_type_parameters)
    vibration_type = insert(:sensor_type, name: "vibration_sensor_type", org: org,
      project: project, parameters: @vibration_type_parameters)

    [energy_type, vibration_type]
  end

  defp insert_sensor(sensor_type, org, project, name) do
    insert(:sensor, sensor_type: sensor_type, org: org, project: project, name: name)
  end

  defp add_sensor_data(sensor_list, org, quantity, time_interval) do
    timestamp = Timex.now() |> DateTime.truncate(:second)
    initializer = prepare_sensor_data(List.first(sensor_list), org, timestamp)

    generator = fn data ->
      sensor_list
      |> Enum.random()
      |> prepare_sensor_data(org, Timex.shift(data.inserted_timestamp, seconds: time_interval))
    end

    initializer
    |> Stream.iterate(generator)
    |> Enum.take(quantity)
    |> Enum.map(fn sensors_data ->
      changeset = SensorsData.changeset(%SensorsData{}, sensors_data)
      Repo.insert!(changeset)
    end)
  end

  defp prepare_sensor_data(sensor, org, timestamp) do
    %{
      org_id: org.id,
      sensor_id: sensor.id,
      parameters: random_data_for_params(sensor),
      inserted_timestamp: timestamp,
      inserted_at: timestamp,
    }
  end

  defp random_data_for_params(sensor) do
    Enum.map(sensor.sensor_type.parameters, fn parameter ->
      %{ name: parameter.name, data_type: parameter.data_type,
        uuid: parameter.uuid, value: to_string(:random.uniform(30)) }
    end)
  end

end
