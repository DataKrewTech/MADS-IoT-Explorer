defmodule AcqdatCore.Test.Support.SensorsData do
  alias AcqdatCore.Schema.EntityManagement.SensorsData
  alias AcqdatCore.Repo
  import AcqdatCore.Support.Factory

  @doc """
  Generates sensor data based on the context provided.

  Check context map for parameters required.
  """
  def put_sensor_data(context) do
    %{
      sensor_data_quantity: quantity,
      time_interval_seconds: time_interval,
      sensor: sensor,
      org: org,
      project: project
    } = context

    sensor_data = add_sensor_data(sensor, org, project, quantity, time_interval)

    [org: org, sensors: sensor, sensor_data: sensor_data]
  end

  defp add_sensor_data(sensor, org, project, quantity, time_interval) do
    timestamp = Timex.now() |> DateTime.truncate(:second)
    initializer = prepare_sensor_data(sensor, org, project, timestamp)

    generator = fn data ->
      prepare_sensor_data(
        sensor,
        org,
        project,
        Timex.shift(data.inserted_timestamp, seconds: time_interval)
      )
    end

    initializer
    |> Stream.iterate(generator)
    |> Enum.take(quantity)
    |> Enum.map(fn sensors_data ->
      changeset = SensorsData.changeset(%SensorsData{}, sensors_data)
      Repo.insert!(changeset)
    end)
  end

  defp prepare_sensor_data(sensor, org, project, timestamp) do
    %{
      org_id: org.id,
      sensor_id: sensor.id,
      project_id: project.id,
      parameters: random_data_for_params(sensor),
      inserted_timestamp: timestamp,
      inserted_at: timestamp
    }
  end

  defp random_data_for_params(sensor) do
    Enum.map(sensor.sensor_type.parameters, fn parameter ->
      %{
        name: parameter.name,
        data_type: parameter.data_type,
        uuid: parameter.uuid,
        value: to_string(:random.uniform(30))
      }
    end)
  end
end
