defmodule AcqdatCore.Seed.EntityManagement.Sensor do
  #TODO
  # alias AcqdatCore.Schema.{Sensor}
  # alias AcqdatCore.Repo

  alias AcqdatCore.Schema.EntityManagement.{Organisation, Asset, Sensor, Project, SensorType}
  alias AcqdatCore.Repo

  @energy_parameters_list [
    %{name: "Voltage", data_type: "string"},
    %{name: "Current", data_type: "string"},
    %{name: "Power", data_type: "string"},
    %{name: "Energy", data_type: "string"}
  ]

  @vibration_parameters_list [
    %{name: "x_axis vel", data_type: "string"},
    %{name: "z_axis vel", data_type: "string"},
    %{name: "x_axis acc", data_type: "string"},
    %{name: "z_axis acc", data_type: "string"}
  ]

  @temperature_parameters_list [
    %{name: "Temperature", data_type: "string"}
  ]

  #NOTE: Commented it, as it is not currently getting used here
  # @occupancy_sensor [
  #   %{name: "Occupancy", data_type: "boolean"}
  # ]

  @air_quality_sensor [
    %{name: "Air Temperature", data_type: "string"},
    %{name: "O2 Level", data_type: "string"},
    %{name: "CO2 Level", data_type: "string"},
    %{name: "CO Level", data_type: "string"},
    %{name: "NH3 Level", data_type: "string"}
  ]

  @soil_moisture_sensor [
    %{name: "Soil Humidity", data_type: "string"},
    %{name: "N Level", data_type: "string"},
    %{name: "P Level", data_type: "string"},
    %{name: "K Level", data_type: "string"}
  ]

  def seed_sensors() do
    [org] = Repo.all(Organisation)
    [project | _] = Repo.all(Project)
    assets = Repo.all(Asset)
    sensors = assets
    |> Enum.map(fn
      %Asset{name: "Wet Process"} = asset ->
        %{org_id: org.id, project_id: project.id, parent_id: asset.id, name: "Energy Meter", parameters: @energy_parameters_list, parent_type: "Asset", slug: Slugger.slugify(asset.slug <> "Energy Meter")}
      %Asset{name: "Dry Process"} = asset ->
        %{org_id: org.id, project_id: project.id, parent_id: asset.id, name: "Temperature Sensor", parameters: @temperature_parameters_list, parent_type: "Asset", slug: Slugger.slugify(asset.slug <> "Temperature Sensor")}
      %Asset{name: "Ipoh Factory"} = asset ->
        %{org_id: org.id, project_id: project.id, parent_id: asset.id, name: "Air Quality Sensor", parameters: @air_quality_sensor, parent_type: "Asset", slug: Slugger.slugify(asset.slug <> "Air Quality Sensor")}
      %Asset{name: "Common Space"} = asset ->
        %{org_id: org.id, project_id: project.id, parent_id: asset.id, name: "Occupancy Sensor", parameters: @air_quality_sensor, parent_type: "Asset", slug: Slugger.slugify(asset.slug <> "Occupancy Sensor")}
      %Asset{name: "Executive Space"} = asset ->
        %{org_id: org.id, project_id: project.id, parent_id: asset.id, name: "Occupancy Sensor", parameters: @air_quality_sensor, parent_type: "Asset", slug: Slugger.slugify(asset.slug <> "Occupancy Sensor")}
      %Asset{name: "Singapore Office"} = asset ->
        %{org_id: org.id, project_id: project.id, parent_id: asset.id, name: "Energy Meter", parameters: @energy_parameters_list, parent_type: "Asset", slug: Slugger.slugify(asset.slug <> "Energy Meter")}
      %Asset{name: "Bintan Factory"} = _asset ->  %{}

      end)
    |> Enum.map(fn sensor ->
      sensor
      |> Map.put(:inserted_at, DateTime.truncate(DateTime.utc_now(), :second))
      |> Map.put(:updated_at, DateTime.truncate(DateTime.utc_now(), :second))
    end)
    sensors1 =
    assets
    |> Enum.map(fn
      %Asset{name: "Wet Process"} = asset ->
        %{org_id: org.id, parent_id: asset.id, project_id: project.id, name: "Vibration Sensor", parameters: @vibration_parameters_list, parent_type: "Asset", slug: Slugger.slugify(asset.slug <> "Vibration Sensot")}
      %Asset{name: "Dry Process"} = _asset -> %{}
      %Asset{name: "Ipoh Factory"} = asset ->
        %{org_id: org.id, parent_id: asset.id, project_id: project.id, name: "Soil Moisture Sensor", parameters: @soil_moisture_sensor, parent_type: "Asset", slug: Slugger.slugify(asset.slug <> "Soil Moisture Sensor")}
      %Asset{name: "Common Space"} = _asset -> %{}
      %Asset{name: "Executive Space"} = _asset -> %{}
      %Asset{name: "Singapore Office"} = _asset -> %{}
      %Asset{name: "Bintan Factory"} = _asset ->  %{}

      end)
    |> Enum.map(fn sensor ->
      sensor
      |> Map.put(:inserted_at, DateTime.truncate(DateTime.utc_now(), :second))
      |> Map.put(:updated_at, DateTime.truncate(DateTime.utc_now(), :second))
    end)

    params =
    %{}
    |> Map.put(:inserted_at, DateTime.truncate(DateTime.utc_now(), :second))
    |> Map.put(:updated_at, DateTime.truncate(DateTime.utc_now(), :second))

    sensors = sensors ++ sensors1
    sensors = sensors -- [params, params, params, params, params, params]

    Enum.reduce(sensors, 0, fn sensor, x ->
      sensor_type = insert_sensor_type(sensor, org, project, x)
      sensor = Map.put_new(sensor, :sensor_type_id, sensor_type.id)
      changeset = Sensor.changeset(%Sensor{}, sensor)
      Repo.insert(changeset)
      x = x + 1
    end)
  end

  defp insert_sensor_type(sensor, org, project, counter) do
    params = %{
        name: "Sensor Type #{counter}",
        metadata: [],
        parameters:  sensor.parameters,
        org_id: org.id,
        generated_by: "user",
        project_id: project.id
      }
    sensor_type = SensorType.changeset(%SensorType{}, params)
      case Repo.insert(sensor_type) do
        {:ok, sensor_type} -> sensor_type
        {:error, error} -> raise RuntimeError, message: "Problem Inserting Sensor Type"
      end
  end
end
