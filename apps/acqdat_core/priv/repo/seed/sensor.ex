defmodule AcqdatCore.Seed.Sensor do
  #TODO
  # alias AcqdatCore.Schema.{Sensor}
  # alias AcqdatCore.Repo

  alias AcqdatCore.Schema.{Organisation, Asset, Sensor}
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

  @occupancy_sensor [
    %{name: "Occupancy", data_type: "boolean"}
  ]

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
    assets = Repo.all(Asset)
    sensors = assets
    |> Enum.map(fn
      %Asset{name: "Wet Process"} = asset ->
        %{org_id: org.id, parent_id: asset.id, name: "Energy Meter", parameters: @energy_parameters_list, parent_type: "Asset", slug: Slugger.slugify(asset.slug <> "Energy Meter")}
      %Asset{name: "Dry Process"} = asset ->
        %{org_id: org.id, parent_id: asset.id, name: "Temperature Sensor", parameters: @temperature_parameters_list, parent_type: "Asset", slug: Slugger.slugify(asset.slug <> "Temperature Sensor")}
      %Asset{name: "Ipoh Factory"} = asset ->
        %{org_id: org.id, parent_id: asset.id, name: "Air Quality Sensor", parameters: @air_quality_sensor, parent_type: "Asset", slug: Slugger.slugify(asset.slug <> "Air Quality Sensor")}
      %Asset{name: "Common Space"} = asset ->
        %{org_id: org.id, parent_id: asset.id, name: "Occupancy Sensor", parameters: @air_quality_sensor, parent_type: "Asset", slug: Slugger.slugify(asset.slug <> "Occupancy Sensor")}
      %Asset{name: "Executive Space"} = asset ->
        %{org_id: org.id, parent_id: asset.id, name: "Occupancy Sensor", parameters: @air_quality_sensor, parent_type: "Asset", slug: Slugger.slugify(asset.slug <> "Occupancy Sensor")}
      %Asset{name: "Singapore Office"} = asset ->  
        %{org_id: org.id, parent_id: asset.id, name: "Energy Meter", parameters: @energy_parameters_list, parent_type: "Asset", slug: Slugger.slugify(asset.slug <> "Energy Meter")}
      %Asset{name: "Bintan Factory"} = asset ->  %{}

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
        %{org_id: org.id, parent_id: asset.id, name: "Vibration Sensor", parameters: @vibration_parameters_list, parent_type: "Asset", slug: Slugger.slugify(asset.slug <> "Vibration Sensot")}
      %Asset{name: "Dry Process"} = asset -> %{}
      %Asset{name: "Ipoh Factory"} = asset ->
        %{org_id: org.id, parent_id: asset.id, name: "Soil Moisture Sensor", parameters: @soil_moisture_sensor, parent_type: "Asset", slug: Slugger.slugify(asset.slug <> "Soil Moisture Sensor")}
      %Asset{name: "Common Space"} = asset -> %{}
      %Asset{name: "Executive Space"} = asset -> %{}
      %Asset{name: "Singapore Office"} = asset -> %{}
      %Asset{name: "Bintan Factory"} = asset ->  %{}

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

    Enum.each(sensors, fn sensor -> 
      changeset = Sensor.changeset(%Sensor{}, sensor)

      require IEx
      IEx.pry
      Repo.insert(changeset)
    end)
    
  end
end
