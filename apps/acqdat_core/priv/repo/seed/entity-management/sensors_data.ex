defmodule AcqdatCore.Seed.EntityManagement.SensorsData do
  import Ecto.Query
  alias AcqdatCore.Schema.EntityManagement.{Sensor, SensorsData, Organisation}
  alias AcqdatCore.Repo

  def seed!() do
    [org] = Repo.all(Organisation)
    vibration_sensor = Sensor |> where([sensor], sensor.name == "Vibration Sensor") |> Repo.one |> Repo.preload([:sensor_type])
    moisture_sensor = Sensor |> where([sensor], sensor.name == "Soil Moisture Sensor") |> Repo.one |> Repo.preload([:sensor_type])
    energy_sensor = Sensor |> where([sensor], sensor.name == "Air Quality Sensor") |> Repo.one |> Repo.preload([:sensor_type])

    sensor_list = sensor_data_list(org.id, vibration_sensor) ++ sensor_data_list(org.id, moisture_sensor) ++ sensor_data_list(org.id, energy_sensor)
    
    Repo.transaction(fn ->
      Enum.each(sensor_list, fn data ->
        changeset = SensorsData.changeset(%SensorsData{}, data)
        Repo.insert(changeset)
      end)
    end)
  end

  defp sensor_data_list(org_id, sensor) do
    current_date = DateTime.utc_now()
    [
      %{org_id: org_id, project_id: sensor.project_id, sensor_id: sensor.id, parameters: generate_parameters_data(sensor), inserted_timestamp: DateTime.truncate(DateTime.add(current_date, -86400, :second), :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org_id, project_id: sensor.project_id, sensor_id: sensor.id, parameters: generate_parameters_data(sensor), inserted_timestamp: DateTime.truncate(current_date, :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org_id, project_id: sensor.project_id, sensor_id: sensor.id, parameters: generate_parameters_data(sensor), inserted_timestamp: DateTime.truncate(DateTime.add(current_date, -6400, :second), :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org_id, project_id: sensor.project_id, sensor_id: sensor.id, parameters: generate_parameters_data(sensor), inserted_timestamp: DateTime.truncate(DateTime.add(current_date, -16400, :second), :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org_id, project_id: sensor.project_id, sensor_id: sensor.id, parameters: generate_parameters_data(sensor), inserted_timestamp: DateTime.truncate(DateTime.add(current_date, -65400, :second), :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org_id, project_id: sensor.project_id, sensor_id: sensor.id, parameters: generate_parameters_data(sensor), inserted_timestamp: DateTime.truncate(DateTime.add(current_date, -186400, :second), :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org_id, project_id: sensor.project_id, sensor_id: sensor.id, parameters: generate_parameters_data(sensor), inserted_timestamp: DateTime.truncate(DateTime.add(current_date, -6900, :second), :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org_id, project_id: sensor.project_id, sensor_id: sensor.id, parameters: generate_parameters_data(sensor), inserted_timestamp: DateTime.truncate(DateTime.add(current_date, -86501, :second), :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org_id, project_id: sensor.project_id, sensor_id: sensor.id, parameters: generate_parameters_data(sensor), inserted_timestamp: DateTime.truncate(DateTime.add(current_date, -6500, :second), :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org_id, project_id: sensor.project_id, sensor_id: sensor.id, parameters: generate_parameters_data(sensor), inserted_timestamp: DateTime.truncate(DateTime.add(current_date, -16900, :second), :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org_id, project_id: sensor.project_id, sensor_id: sensor.id, parameters: generate_parameters_data(sensor), inserted_timestamp: DateTime.truncate(DateTime.add(current_date, -65500, :second), :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org_id, project_id: sensor.project_id, sensor_id: sensor.id, parameters: generate_parameters_data(sensor), inserted_timestamp: DateTime.truncate(DateTime.add(current_date, -286400, :second), :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)},
      %{org_id: org_id, project_id: sensor.project_id, sensor_id: sensor.id, parameters: generate_parameters_data(sensor), inserted_timestamp: DateTime.truncate(DateTime.add(current_date, -6890, :second), :second), inserted_at: DateTime.truncate(DateTime.utc_now(), :second), updated_at: DateTime.truncate(DateTime.utc_now(), :second)}
    ]
  end

  defp generate_parameters_data(sensor) do
    Enum.map(sensor.sensor_type.parameters, fn parameter ->
      %{
        name: parameter.name,
        data_type: parameter.data_type,
        uuid: parameter.uuid,
        value: to_string(Enum.random(10..100))
      }
    end)
  end
end