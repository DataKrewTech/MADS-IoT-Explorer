defmodule AcqdatCore.Seed.DataInsights.Topology do
  import Ecto.Query
  alias AcqdatCore.Model.EntityManagement.{Asset, Sensor, SensorType, AssetType, Project}
  alias AcqdatCore.Schema.EntityManagement.Asset, as: AssetSchema
  alias AcqdatCore.Schema.RoleManagement.User
  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.EntityManagement.SensorType.Parameters
  alias AcqdatCore.Schema.EntityManagement.SensorsData
  alias AcqdatCore.Schema.EntityManagement.SensorsData.Parameters, as: Sparameters

  # number of months to seed data for
  @months 1

  # Data Seed Info::
  # 6 Buildings
  #   ->Red(2f)
  #   ->Green(4f)
  #   ->Blue(6f)
  #   ->Yellow(3f)
  #   ->White(5f)
  #   ->Brown(7f)
  #   * Each Floor has apartments
  #   * Race(Indian, African, European, Korean, Japanese, Chinese)
  #   * No of rooms in each apartment btw 2,3,4 or 5
  #   * No of kids(0, 1, 2, 3)
  #   * Playground name only
  #   * Each apt has 1 EnergyMeter and 1 HeatMeter

  # Building metadata configuration(at present being used for floors)
  # Used to insert number of floors per building. Floors should be string.
  @building_metadata %{
    "Building Red" => %{"floors" => "1"},
    "Building Blue" => %{"floors" => "2"},
    "Building Green" => %{"floors" => "3"},
    "Building Yellow" => %{"floors" => "1"},
    "Building White" => %{"floors" => "2"},
    "Building Brown" => %{"floors" => "3"},
  }

  # configures how many apartments per floor
  @building_apartment_Per_floor 2

  def seed() do
    org = Repo.get(Organisation, 1)
    creator = creator()
    Repo.transaction(fn ->
      {:ok, project} = Project.create(%{name: "DataInsights Demo", org_id:
        org.id, creator_id: creator.id, lead_ids: [], user_ids: []})

      asset_types = %{
        building_asset_type: seed_asset_type(org.id, project.id, "Building"),
        apartment_asset_type: seed_asset_type(org.id, project.id, "Apartment"),
        playground_asset_type: seed_asset_type(org.id, project.id, "PlayGround")
      }

      build_topology(asset_types, creator, org)
    end, timeout: :infinity)
  end

  defp creator() do
    Repo.get_by(User, org_id: 1)
  end

  def build_topology(asset_types, user, org) do
    %{
      building_asset_type: building_asset_type,
      apartment_asset_type: apartment_asset_type,
      playground_asset_type: playground_asset_type
    } = asset_types

    %{id: asset_type_id, org_id: org_id, project_id: project_id} = building_asset_type

    {:ok, energy_mtr_sensor_type} = SensorType.create(%{name: "Energy Meter", project_id: project_id, org_id: org_id, parameters: gen_sensor_type_params("Energy Meter")})

    {:ok, heat_mtr_sensor_type} = SensorType.create(%{name: "Heat Meter", project_id: project_id, org_id: org_id, parameters: gen_sensor_type_params("Heat Meter")})

    {:ok, occupancy_sensor_type} = SensorType.create(%{name: "Occupancy Sensor", project_id: project_id, org_id: org_id, parameters: gen_sensor_type_params("Occupancy Sensor")})

    buildings = ["Red", "Green", "Blue", "Yellow", "White", "Brown"]

    Enum.each(buildings, fn ele ->
      {:ok, building} = build_root_asset(
          "Building #{ele}",
          org_id,
          org.name,
          project_id,
          user.id,
          building_asset_type
        )

      no_of_floors = fetch_metadata_val("No of Floors", "Building #{ele}")

      playground = build_asset_map("PlayGround #{ele}", org_id, project_id, user.id, playground_asset_type)

      {:ok, playground} = Asset.add_as_child(building, playground, :child)

      occup_sensor =
      build_sensor_map(
        "Occupancy Sensor #{ele}",
        org_id,
        project_id,
        occupancy_sensor_type.id,
        playground.id
      )

      {:ok, occup_sensor} = Sensor.create(occup_sensor)
      occup_sensor = struct(occup_sensor, [sensor_type: occupancy_sensor_type])
      data = gen_sensor_type_data("occupancy", occup_sensor)
      Repo.insert_all(SensorsData, data)

      {no_of_floors, _} = Integer.parse(no_of_floors)

      Enum.each(1..no_of_floors, fn floor_no ->
        Enum.each(1..@building_apartment_Per_floor, fn apt_no ->
          apt_name = "Apt #{ele} #{floor_no}#{apt_no}"
          apt = build_asset_map(apt_name, org_id, project_id, user.id, apartment_asset_type)
          {:ok, apt} = Asset.add_as_child(building, apt, :child)
          energy_sensor =
            build_sensor_map(
              "Energy Mtr #{ele} #{floor_no}#{apt_no}",
              org_id,
              project_id,
              energy_mtr_sensor_type.id,
              apt.id
            )

            heat_sensor =
            build_sensor_map(
              "Heat Mtr #{ele} #{floor_no}#{apt_no}",
              org_id,
              project_id,
              heat_mtr_sensor_type.id,
              apt.id
            )

            {:ok, energy_sensor} = Sensor.create(energy_sensor)
            energy_sensor = struct(energy_sensor, [sensor_type: energy_mtr_sensor_type])
            energy_data = gen_sensor_type_data("energy", energy_sensor)
            Repo.insert_all(SensorsData, energy_data)
            {:ok, heat_mtr_sen} = Sensor.create(heat_sensor)
            heat_mtr_sen = struct(heat_mtr_sen, [sensor_type: heat_mtr_sensor_type])
            heat_data = gen_sensor_type_data("heat", heat_mtr_sen)
            Repo.insert_all(SensorsData, heat_data)
        end)
      end)
    end)
  end

  defp build_sensor_map(name, org_id, project_id, sensor_type_id, parent_id) do
    %{
      name: name,
      org_id: org_id,
      project_id: project_id,
      sensor_type_id: sensor_type_id,
      parent_id: parent_id,
      parent_type: "Asset",
      metadata: []
    }
  end

  defp build_asset_map(name, org_id, project_id, creator_id, asset_type) do
    %AssetSchema{
      name: name,
      org_id: org_id,
      project_id: project_id,
      creator_id: creator_id,
      asset_type_id: asset_type.id,
      mapped_parameters: [],
      owner_id: creator_id,
      properties: [],
      metadata: generate_asset_metadata(asset_type, name)
    }
  end

  defp build_root_asset(name, org_id, org_name, project_id, creator_id, asset_type) do
    Asset.add_as_root(%{
      name: name,
      org_id: org_id,
      org_name: org_name,
      project_id: project_id,
      creator_id: creator_id,
      asset_type_id: asset_type.id,
      mapped_parameters: [],
      owner_id: creator_id,
      properties: [],
      metadata: generate_asset_metadata(asset_type, name)
    })
  end

  defp generate_asset_metadata(asset_type, asset_name) do
    Enum.map(asset_type.metadata, fn  metadata ->
      %{
        name: metadata.name,
        data_type: metadata.data_type,
        uuid: metadata.uuid,
        value: fetch_metadata_val(metadata.name, asset_name)
      }
    end)
  end

  defp fetch_metadata_val(metadata_name, asset_name) when metadata_name == "Color" do
    "Building " <> color = asset_name
    color
  end

  defp fetch_metadata_val(metadata_name, asset_name) do
    IO.inspect({asset_name, metadata_name})
    case {asset_name, metadata_name} do
      {"Building Red", "No of Floors"} ->
        @building_metadata[asset_name]["floors"]
      {"Building Green", "No of Floors"} ->
        @building_metadata[asset_name]["floors"]
      {"Building Blue", "No of Floors"} ->
        @building_metadata[asset_name]["floors"]
      {"Building Yellow", "No of Floors"} ->
        @building_metadata[asset_name]["floors"]
      {"Building White", "No of Floors"} ->
        @building_metadata[asset_name]["floors"]
      {"Building Brown", "No of Floors"} ->
        @building_metadata[asset_name]["floors"]
      {_, "Date Of Construction"} ->
        "#{Enum.random(Date.range(~D[1999-01-01], ~D[2000-01-01]))}"
      {_, "No of Rooms"} ->
        "#{Enum.random(2..4)}"
      {_, "Race"} ->
        Enum.random(["American", "Indian", "African", "Korean", "Japanese", "Chinese"])
      {_, "Painted"} ->
        "#{Enum.random([true, false])}"
      {_, "No of Kids"} ->
        "#{Enum.random(0..3)}"
    end
  end

  def seed_asset_type(org_id, project_id, asset_type) do
    metadata = fetch_asset_type_metadata(asset_type)
    {:ok, data} = AssetType.create(%{name: asset_type, metadata: metadata, org_id: org_id, project_id: project_id})
    data
  end

  defp gen_sensor_type_params(type) do
    case type do
      "Energy Meter" ->
        [
          %{
            name: "Voltage",
            data_type: "string",
            uuid: UUID.uuid1(:hex)
          },
          %{
            name: "Current",
            data_type: "string",
            uuid: UUID.uuid1(:hex)
          },
          %{
            name: "Power",
            data_type: "string",
            uuid: UUID.uuid1(:hex)
          },
          %{
            name: "Energy",
            data_type: "string",
            uuid: UUID.uuid1(:hex)
          }
        ]

      "Heat Meter" ->
        [
          %{
            name: "temp",
            data_type: "string",
            uuid: UUID.uuid1(:hex)
          }
        ]

      "Occupancy Sensor" ->
        [
          %{
            name: "Occupancy",
            data_type: "string",
            uuid: UUID.uuid1(:hex)
          }
        ]

      _ ->
        []
    end
  end

  def fetch_asset_type_metadata(asset_type) do
    case asset_type do
      "Building" ->
        [
          %{
            name: "No of Floors",
            data_type: "integer",
            unit: ""
          },
          %{
            name: "Color",
            data_type: "string",
            unit: ""
          },
          %{
            name: "Date Of Construction",
            data_type: "date",
            unit: ""
          }
        ]
      "Apartment" ->
        [
          %{
            name: "No of Rooms",
            data_type: "integer",
            unit: ""
          },
          %{
            name: "Race",
            data_type: "string",
            unit: ""
          },
          %{
            name: "Painted",
            data_type: "boolean",
            unit: ""
          },
          %{
            name: "No of Kids",
            data_type: "integer",
            unit: ""
          }
        ]
      _ ->
        []
    end
  end

  def gen_sensor_type_data("energy", sensor) do
    duration = @months * 30 # duration in months
    interval = 10 # interval in minutes
    iterator = get_time_iterator(duration, interval)

    Enum.map(iterator, fn time ->
      time = time = time |> DateTime.from_naive!("Etc/UTC") |> DateTime.truncate(:second)
      %{
        sensor_id: sensor.id, project_id: sensor.project_id, org_id: sensor.org_id,
        inserted_at: time,
        inserted_timestamp: time,
        parameters: energy_parameters(sensor, interval)
      }
    end)
  end

  defp energy_parameters(sensor, duration) do
    sensor.sensor_type.parameters
    |> Enum.reduce(%{}, fn
      %Parameters{name: "Voltage"} = params, acc ->
        result = create_parameter_struct(params, Enum.random(230..240))
        Map.put(acc, "Voltage", result)
      %Parameters{name: "Current"} = params, acc ->
        result = create_parameter_struct(params, Enum.random(1..10))
        Map.put(acc, "Current", result)
      %Parameters{name: "Power"} = params, acc ->
        voltage = Map.get(acc, "Voltage") |> Map.get(:value)
        current = Map.get(acc, "Current") |> Map.get(:value)
        power = voltage * current * 0.9
        result = create_parameter_struct(params, power)
        Map.put(acc, "Power", result)
      %Parameters{name: "Energy"} = params, acc ->
        power = Map.get(acc, "Power") |> Map.get(:value)
        energy = (power * duration) / 60
        result = create_parameter_struct(params, energy)
        Map.put(acc, "Energy", result)
    end)
    |> Enum.map(fn {key, value} ->
      value
    end)
  end

  def gen_sensor_type_data("heat", sensor) do
    duration = @months * 30 # duration in months
    interval = 10 # interval in minutes
    iterator = get_time_iterator(duration, interval)

    Enum.map(iterator, fn time ->
      time = time = time |> DateTime.from_naive!("Etc/UTC") |> DateTime.truncate(:second)
      %{
        sensor_id: sensor.id, project_id: sensor.project_id, org_id: sensor.org_id,
        inserted_at: time,
        inserted_timestamp: time,
        parameters: heat_parameters(sensor)
      }
    end)
  end

  defp heat_parameters(sensor) do
    [param] = sensor.sensor_type.parameters
    result = create_parameter_struct(param, Enum.random(20..35))
    [result]
  end

  def gen_sensor_type_data("occupancy", sensor) do
    duration = @months * 30 # duration in months
    interval = 10 # interval in minutes
    iterator = get_time_iterator(duration, interval)

    Enum.map(iterator, fn time ->
      time = time |> DateTime.from_naive!("Etc/UTC") |> DateTime.truncate(:second)
      %{
        sensor_id: sensor.id, project_id: sensor.project_id, org_id: sensor.org_id,
        inserted_at: time,
        inserted_timestamp: time,
        parameters: occupancy_parameters(sensor)
      }
    end)
  end

  defp occupancy_parameters(sensor) do
    [param] = sensor.sensor_type.parameters
    result = create_parameter_struct(param, (:rand.uniform 10)/10)
    [result]
  end

  defp create_parameter_struct(param, value) do
    struct(
      Sparameters,
      [
        uuid: param.uuid,
        name: param.name,
        data_type: param.data_type,
        value: value
      ]
    )
  end

  defp get_time_iterator(duration, interval) do
    time_from = Timex.shift(Timex.now(), days: -duration)
    Timex.Interval.new(from: time_from, until: [days: duration],
      step: [minutes: interval])
  end
end
