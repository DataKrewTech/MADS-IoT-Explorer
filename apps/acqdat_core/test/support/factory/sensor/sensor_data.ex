
defmodule AcqdatCore.Test.Support.SensorsData do
  import Ecto.Query
  alias AcqdatCore.Schema.EntityManagement.{Sensor, SensorsData, Organisation}
  alias AcqdatCore.Repo

  @energy_parameters_list_1 [
    %{name: "Voltage", data_type: "string", value: "100"},
    %{name: "Current", data_type: "string", value: "22"},
    %{name: "Power", data_type: "string", value: "22"},
    %{name: "Energy", data_type: "string", value: "33"}
  ]

  @energy_parameters_list_2 [
    %{name: "Voltage", data_type: "string", value: "90"},
    %{name: "Current", data_type: "string", value: "40"},
    %{name: "Power", data_type: "string", value: "10"},
    %{name: "Energy", data_type: "string", value: "30"}
  ]

  @vibration_parameters_list_1 [
    %{name: "x_axis vel", data_type: "string", value: "11.2", uuid: UUID.uuid1(:hex)},
    %{name: "z_axis vel", data_type: "string", value: "12.2", uuid: UUID.uuid1(:hex)},
    %{name: "x_axis acc", data_type: "string", value: "13.9", uuid: UUID.uuid1(:hex)},
    %{name: "z_axis acc", data_type: "string", value: "90.2", uuid: UUID.uuid1(:hex)}
  ]

  @vibration_parameters_list_2 [
    %{name: "x_axis vel", data_type: "string", value: "90", uuid: UUID.uuid1(:hex)},
    %{name: "z_axis vel", data_type: "string", value: "20", uuid: UUID.uuid1(:hex)},
    %{name: "x_axis acc", data_type: "string", value: "30", uuid: UUID.uuid1(:hex)},
    %{name: "z_axis acc", data_type: "string", value: "40", uuid: UUID.uuid1(:hex)}
  ]

  def seed!() do
    [org] = Repo.all(Organisation)
    vibration_sensor = Sensor |> where([sensor], sensor.name == "Vibration Sensor") |> Repo.one
    [energy_sensor | _] = Sensor |> where([sensor], sensor.name == "Energy Meter") |> Repo.all
    current_date = DateTime.utc_now()

    #TODO: Need to Refactor this code
    sensors_data = [
      %{org_id: org.id, sensor_id: vibration_sensor.id, parameters: @vibration_parameters_list_1, inserted_timestamp: DateTime.truncate(DateTime.add(current_date, 86400, :second), :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org.id, sensor_id: vibration_sensor.id, parameters: @vibration_parameters_list_1, inserted_timestamp: DateTime.truncate(current_date, :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org.id, sensor_id: vibration_sensor.id, parameters: @vibration_parameters_list_1, inserted_timestamp: DateTime.truncate(DateTime.add(current_date, 6400, :second), :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org.id, sensor_id: vibration_sensor.id, parameters: @vibration_parameters_list_2, inserted_timestamp: DateTime.truncate(DateTime.add(current_date, 16400, :second), :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org.id, sensor_id: vibration_sensor.id, parameters: @vibration_parameters_list_2, inserted_timestamp: DateTime.truncate(DateTime.add(current_date, 65400, :second), :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org.id, sensor_id: vibration_sensor.id, parameters: @vibration_parameters_list_1, inserted_timestamp: DateTime.truncate(DateTime.add(current_date, 186400, :second), :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org.id, sensor_id: vibration_sensor.id, parameters: @vibration_parameters_list_2, inserted_timestamp: DateTime.truncate(DateTime.add(current_date, 6900, :second), :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org.id, sensor_id: energy_sensor.id, parameters: @energy_parameters_list_1, inserted_timestamp: DateTime.truncate(DateTime.add(current_date, 86400, :second), :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org.id, sensor_id: energy_sensor.id, parameters: @energy_parameters_list_1, inserted_timestamp: DateTime.truncate(current_date, :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org.id, sensor_id: energy_sensor.id, parameters: @energy_parameters_list_1, inserted_timestamp: DateTime.truncate(DateTime.add(current_date, 6400, :second), :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org.id, sensor_id: energy_sensor.id, parameters: @energy_parameters_list_2, inserted_timestamp: DateTime.truncate(DateTime.add(current_date, 16400, :second), :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org.id, sensor_id: energy_sensor.id, parameters: @energy_parameters_list_2, inserted_timestamp: DateTime.truncate(DateTime.add(current_date, 96400, :second), :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org.id, sensor_id: energy_sensor.id, parameters: @energy_parameters_list_1, inserted_timestamp: DateTime.truncate(DateTime.add(current_date, 786400, :second), :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org.id, sensor_id: energy_sensor.id, parameters: @energy_parameters_list_2, inserted_timestamp: DateTime.truncate(DateTime.add(current_date, 6800, :second), :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)}
    ]

    Repo.transaction(fn ->
      Enum.each(sensors_data, fn data ->
        changeset = SensorsData.changeset(%SensorsData{}, data)
        Repo.insert(changeset)
      end)
    end)
  end
end
