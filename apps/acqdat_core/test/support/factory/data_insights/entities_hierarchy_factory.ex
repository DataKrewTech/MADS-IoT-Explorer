defmodule AcqdatCore.Test.Support.DataInsights.EntitiesHirerachyFactory do
  import Ecto.Query
  alias AcqdatCore.Model.EntityManagement.{Asset, Sensor}
  alias AcqdatCore.Schema.EntityManagement.Asset, as: AssetSchema
  alias AcqdatCore.Schema.EntityManagement.Sensor, as: SensorSchema
  alias AcqdatCore.Schema.EntityManagement.SensorsData, as: SensorsDataSchema
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Repo

  def setup_tree() do
    # Tree Topology initialization
    # |- Place 1
    #     |- Building 1
    #         |- Apartment 1.1
    #             |- Energy Mtr 1.1
    #         |- Apartment 1.2
    #             |- Energy Mtr 1.2
    #         |- PlayGround 1
    #             |- Occupancy Sensor 1.1
    #     |- Building 2
    #         |- Apartment 2.1
    #             |- Energy Mtr 2.1
    #         |- Apartment 2.2
    #             |- Energy Mtr 2.1
    #         |- Apartment 2.3
    #         |- PlayGround 2
    #              |- Occupancy Sensor 2.1
    #     |- Building 3
    #         |- Apartment 3.1
    #             |- Energy Mtr 3.1
    #         |- Apartment 3.2
    #             |- Energy Mtr 3.1
    #         |- PlayGround 3

    org = insert(:organisation)
    project = insert(:project, org: org)
    place_asset_type = insert(:asset_type, name: "Place")

    building_asset_type =
      insert(:asset_type, name: "Building", metadata: gen_params_or_metadata("Building"))

    apartment_asset_type =
      insert(:asset_type, name: "Apartment", metadata: gen_params_or_metadata("Apartment"))

    playground_asset_type =
      insert(:asset_type, name: "PlayGround", metadata: gen_params_or_metadata("Apartment"))

    energy_mtr_sensor_type =
      insert(:sensor_type,
        name: "Energy Meter",
        parameters: gen_params_or_metadata("Energy Meter")
      )

    temp_sensor_type =
      insert(:sensor_type, name: "Temp Sensor", parameters: gen_params_or_metadata("Temp Sensor"))

    occupancy_sensor_type =
      insert(:sensor_type,
        name: "Occupancy Sensor",
        parameters: gen_params_or_metadata("Occupancy Sensor")
      )

    user = insert(:user)

    building_1 =
      build_asset_map(
        "Building 1",
        org.id,
        org.name,
        project.id,
        user.id,
        building_asset_type.id,
        building_asset_type
      )

    building_2 =
      build_asset_map(
        "Building 2",
        org.id,
        org.name,
        project.id,
        user.id,
        building_asset_type.id,
        building_asset_type
      )

    building_3 =
      build_asset_map(
        "Building 3",
        org.id,
        org.name,
        project.id,
        user.id,
        building_asset_type.id,
        building_asset_type
      )

    apt_1_1 =
      build_asset_map(
        "Apartment 1.1",
        org.id,
        org.name,
        project.id,
        user.id,
        apartment_asset_type.id,
        apartment_asset_type
      )

    apt_1_2 =
      build_asset_map(
        "Apartment 1.2",
        org.id,
        org.name,
        project.id,
        user.id,
        apartment_asset_type.id,
        apartment_asset_type
      )

    playground_1 =
      build_asset_map(
        "PlayGround 1",
        org.id,
        org.name,
        project.id,
        user.id,
        playground_asset_type.id,
        apartment_asset_type
      )

    apt_2_1 =
      build_asset_map(
        "Apartment 2.1",
        org.id,
        org.name,
        project.id,
        user.id,
        apartment_asset_type.id,
        apartment_asset_type
      )

    apt_2_2 =
      build_asset_map(
        "Apartment 2.2",
        org.id,
        org.name,
        project.id,
        user.id,
        apartment_asset_type.id,
        apartment_asset_type
      )

    apt_2_3 =
      build_asset_map(
        "Apartment 2.3",
        org.id,
        org.name,
        project.id,
        user.id,
        apartment_asset_type.id,
        apartment_asset_type
      )

    playground_2 =
      build_asset_map(
        "PlayGround 2",
        org.id,
        org.name,
        project.id,
        user.id,
        playground_asset_type.id,
        apartment_asset_type
      )

    apt_3_1 =
      build_asset_map(
        "Apartment 3.1",
        org.id,
        org.name,
        project.id,
        user.id,
        apartment_asset_type.id,
        apartment_asset_type
      )

    apt_3_2 =
      build_asset_map(
        "Apartment 3.2",
        org.id,
        org.name,
        project.id,
        user.id,
        apartment_asset_type.id,
        apartment_asset_type
      )

    playground_3 =
      build_asset_map(
        "PlayGround 3",
        org.id,
        org.name,
        project.id,
        user.id,
        playground_asset_type.id,
        playground_asset_type
      )

    {:ok, place_1} =
      Asset.add_as_root(
        build_asset_root_map(
          "Place 1",
          org.id,
          org.name,
          project.id,
          user.id,
          place_asset_type.id
        )
      )

    {:ok, building_1} = Asset.add_as_child(place_1, building_1, :child)
    {:ok, building_2} = Asset.add_as_child(place_1, building_2, :child)
    {:ok, building_3} = Asset.add_as_child(place_1, building_3, :child)

    {:ok, apt_1_1} = Asset.add_as_child(building_1, apt_1_1, :child)
    {:ok, apt_1_2} = Asset.add_as_child(building_1, apt_1_2, :child)
    {:ok, playground_1} = Asset.add_as_child(building_1, playground_1, :child)

    {:ok, apt_2_1} = Asset.add_as_child(building_2, apt_2_1, :child)
    {:ok, apt_2_2} = Asset.add_as_child(building_2, apt_2_2, :child)
    {:ok, apt_2_3} = Asset.add_as_child(building_2, apt_2_3, :child)
    {:ok, playground_2} = Asset.add_as_child(building_2, playground_2, :child)

    {:ok, apt_3_1} = Asset.add_as_child(building_3, apt_3_1, :child)
    {:ok, apt_3_2} = Asset.add_as_child(building_3, apt_3_2, :child)
    {:ok, playground_3} = Asset.add_as_child(building_3, playground_3, :child)

    occup_1_1 =
      build_sensor_map(
        "Occupancy Sensor 1.1",
        org.id,
        project.id,
        occupancy_sensor_type.id,
        playground_1.id
      )

    {:ok, occup_1_1} = Sensor.create(occup_1_1)

    energy_mtr_1_1 =
      build_sensor_map(
        "Energy Mtr 1.1",
        org.id,
        project.id,
        energy_mtr_sensor_type.id,
        apt_1_1.id
      )

    energy_mtr_1_2 =
      build_sensor_map(
        "Energy Mtr 1.2",
        org.id,
        project.id,
        energy_mtr_sensor_type.id,
        apt_1_2.id
      )

    {:ok, energy_mtr_1_1} = Sensor.create(energy_mtr_1_1)
    {:ok, energy_mtr_1_2} = Sensor.create(energy_mtr_1_2)

    occup_2_1 =
      build_sensor_map(
        "Occupancy Sensor 2.1",
        org.id,
        project.id,
        occupancy_sensor_type.id,
        playground_2.id
      )

    {:ok, occup_2_1} = Sensor.create(occup_2_1)

    energy_mtr_2_1 =
      build_sensor_map(
        "Energy Mtr 2.1",
        org.id,
        project.id,
        energy_mtr_sensor_type.id,
        apt_2_1.id
      )

    energy_mtr_2_2 =
      build_sensor_map(
        "Energy Mtr 2.2",
        org.id,
        project.id,
        energy_mtr_sensor_type.id,
        apt_2_2.id
      )

    {:ok, energy_mtr_2_1} = Sensor.create(energy_mtr_2_1)
    {:ok, energy_mtr_2_2} = Sensor.create(energy_mtr_2_2)

    energy_mtr_3_1 =
      build_sensor_map(
        "Energy Mtr 3.1",
        org.id,
        project.id,
        energy_mtr_sensor_type.id,
        apt_3_1.id
      )

    energy_mtr_3_2 =
      build_sensor_map(
        "Energy Mtr 3.2",
        org.id,
        project.id,
        energy_mtr_sensor_type.id,
        apt_3_2.id
      )

    {:ok, energy_mtr_3_1} = Sensor.create(energy_mtr_3_1)
    {:ok, energy_mtr_3_2} = Sensor.create(energy_mtr_3_2)

    temp_sensors =
      SensorSchema
      |> where([sensor], sensor.sensor_type_id == ^temp_sensor_type.id)
      |> Repo.all()
      |> Repo.preload([:sensor_type])

    occup_sensors =
      SensorSchema
      |> where([sensor], sensor.sensor_type_id == ^occupancy_sensor_type.id)
      |> Repo.all()
      |> Repo.preload([:sensor_type])

    energy_sensors =
      SensorSchema
      |> where([sensor], sensor.sensor_type_id == ^energy_mtr_sensor_type.id)
      |> Repo.all()
      |> Repo.preload([:sensor_type])

    sensor_list =
      sensor_data_list(org.id, temp_sensors) ++
        sensor_data_list(org.id, occup_sensors) ++ sensor_data_list(org.id, energy_sensors)

    Repo.transaction(fn ->
      Enum.each(sensor_list, fn data ->
        changeset = SensorsDataSchema.changeset(%SensorsDataSchema{}, data)
        Repo.insert(changeset)
      end)
    end)

    {:ok, {org.id, project.id}}
  end

  defp sensor_data_list(org_id, sensors) do
    Enum.reduce(sensors, [], fn sensor, acc ->
      acc ++ gen_sensors_data(org_id, sensor)
    end)
  end

  defp gen_sensors_data(org_id, sensor) do
    current_date = DateTime.utc_now()

    [
      %{
        org_id: org_id,
        project_id: sensor.project_id,
        sensor_id: sensor.id,
        parameters: generate_parameters_data(sensor),
        inserted_timestamp:
          DateTime.truncate(DateTime.add(current_date, -86400, :second), :second),
        inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
        updated_at: DateTime.truncate(DateTime.utc_now(), :second)
      },
      %{
        org_id: org_id,
        project_id: sensor.project_id,
        sensor_id: sensor.id,
        parameters: generate_parameters_data(sensor),
        inserted_timestamp: DateTime.truncate(current_date, :second),
        inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
        updated_at: DateTime.truncate(DateTime.utc_now(), :second)
      },
      %{
        org_id: org_id,
        project_id: sensor.project_id,
        sensor_id: sensor.id,
        parameters: generate_parameters_data(sensor),
        inserted_timestamp:
          DateTime.truncate(DateTime.add(current_date, -6400, :second), :second),
        inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
        updated_at: DateTime.truncate(DateTime.utc_now(), :second)
      },
      %{
        org_id: org_id,
        project_id: sensor.project_id,
        sensor_id: sensor.id,
        parameters: generate_parameters_data(sensor),
        inserted_timestamp:
          DateTime.truncate(DateTime.add(current_date, -16400, :second), :second),
        inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
        updated_at: DateTime.truncate(DateTime.utc_now(), :second)
      },
      %{
        org_id: org_id,
        project_id: sensor.project_id,
        sensor_id: sensor.id,
        parameters: generate_parameters_data(sensor),
        inserted_timestamp:
          DateTime.truncate(DateTime.add(current_date, -65400, :second), :second),
        inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
        updated_at: DateTime.truncate(DateTime.utc_now(), :second)
      },
      %{
        org_id: org_id,
        project_id: sensor.project_id,
        sensor_id: sensor.id,
        parameters: generate_parameters_data(sensor),
        inserted_timestamp:
          DateTime.truncate(DateTime.add(current_date, -186_400, :second), :second),
        inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
        updated_at: DateTime.truncate(DateTime.utc_now(), :second)
      },
      %{
        org_id: org_id,
        project_id: sensor.project_id,
        sensor_id: sensor.id,
        parameters: generate_parameters_data(sensor),
        inserted_timestamp:
          DateTime.truncate(DateTime.add(current_date, -6900, :second), :second),
        inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
        updated_at: DateTime.truncate(DateTime.utc_now(), :second)
      },
      %{
        org_id: org_id,
        project_id: sensor.project_id,
        sensor_id: sensor.id,
        parameters: generate_parameters_data(sensor),
        inserted_timestamp:
          DateTime.truncate(DateTime.add(current_date, -86501, :second), :second),
        inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
        updated_at: DateTime.truncate(DateTime.utc_now(), :second)
      },
      %{
        org_id: org_id,
        project_id: sensor.project_id,
        sensor_id: sensor.id,
        parameters: generate_parameters_data(sensor),
        inserted_timestamp:
          DateTime.truncate(DateTime.add(current_date, -6500, :second), :second),
        inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
        updated_at: DateTime.truncate(DateTime.utc_now(), :second)
      },
      %{
        org_id: org_id,
        project_id: sensor.project_id,
        sensor_id: sensor.id,
        parameters: generate_parameters_data(sensor),
        inserted_timestamp:
          DateTime.truncate(DateTime.add(current_date, -16900, :second), :second),
        inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
        updated_at: DateTime.truncate(DateTime.utc_now(), :second)
      },
      %{
        org_id: org_id,
        project_id: sensor.project_id,
        sensor_id: sensor.id,
        parameters: generate_parameters_data(sensor),
        inserted_timestamp:
          DateTime.truncate(DateTime.add(current_date, -65500, :second), :second),
        inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
        updated_at: DateTime.truncate(DateTime.utc_now(), :second)
      },
      %{
        org_id: org_id,
        project_id: sensor.project_id,
        sensor_id: sensor.id,
        parameters: generate_parameters_data(sensor),
        inserted_timestamp:
          DateTime.truncate(DateTime.add(current_date, -286_400, :second), :second),
        inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
        updated_at: DateTime.truncate(DateTime.utc_now(), :second)
      },
      %{
        org_id: org_id,
        project_id: sensor.project_id,
        sensor_id: sensor.id,
        parameters: generate_parameters_data(sensor),
        inserted_timestamp:
          DateTime.truncate(DateTime.add(current_date, -6890, :second), :second),
        inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
        updated_at: DateTime.truncate(DateTime.utc_now(), :second)
      }
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

  defp build_asset_map(name, org_id, _org_name, project_id, creator_id, asset_type_id, asset_type) do
    %AssetSchema{
      name: name,
      org_id: org_id,
      project_id: project_id,
      creator_id: creator_id,
      asset_type_id: asset_type_id,
      mapped_parameters: [],
      owner_id: creator_id,
      properties: [],
      metadata: gen_asset_metadata(asset_type)
    }
  end

  defp build_asset_root_map(name, org_id, org_name, project_id, creator_id, asset_type_id) do
    %{
      name: name,
      org_id: org_id,
      org_name: org_name,
      project_id: project_id,
      creator_id: creator_id,
      asset_type_id: asset_type_id,
      mapped_parameters: [],
      owner_id: creator_id,
      properties: [],
      metadata: [
        %{
          name: "location",
          data_type: "string",
          unit: "unit",
          value: "demo location"
        }
      ]
    }
  end

  defp gen_asset_metadata(%{name: name, metadata: metadata}) do
    Enum.map(metadata, fn parameter ->
      %{
        name: parameter.name,
        data_type: parameter.data_type,
        uuid: parameter.uuid,
        value: get_metadata_value(parameter.name)
      }
    end)
  end

  defp get_metadata_value(type) do
    case type do
      "color" ->
        Enum.random(["white", "blue", "orange", "yellow", "pink"])

      "date of constr" ->
        "#{Date.utc_today()}"

      "no of floors" ->
        "#{Enum.random(1..10)}"

      "painted" ->
        "#{Enum.random([true, false])}"

      "floor no" ->
        "#{Enum.random(1..10)}"

      "no of rooms" ->
        "#{Enum.random(1..4)}"

      "no of kids" ->
        "#{Enum.random(0..4)}"

      "ethnicity" ->
        "#{Enum.random(["American", "Indian", "African", "Korean", "Japanese"])}"

      "no of instruments" ->
        "#{Enum.random(2..10)}"

      _ ->
        ""
    end
  end

  defp gen_params_or_metadata(type) do
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

      "Temp Sensor" ->
        [
          %{
            name: "Temperature",
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

      "Building" ->
        [
          %{
            name: "color",
            data_type: "string",
            uuid: UUID.uuid1(:hex)
          },
          %{
            name: "date of constr",
            data_type: "date",
            uuid: UUID.uuid1(:hex)
          },
          %{
            name: "no of floors",
            data_type: "integer",
            uuid: UUID.uuid1(:hex)
          }
        ]

      "Apartment" ->
        [
          %{
            name: "painted",
            data_type: "boolean",
            uuid: UUID.uuid1(:hex)
          },
          %{
            name: "floor no",
            data_type: "integer",
            uuid: UUID.uuid1(:hex)
          },
          %{
            name: "no of rooms",
            data_type: "integer",
            uuid: UUID.uuid1(:hex)
          },
          %{
            name: "no of kids",
            data_type: "integer",
            uuid: UUID.uuid1(:hex)
          },
          %{
            name: "ethnicity",
            data_type: "string",
            uuid: UUID.uuid1(:hex)
          }
        ]

      _ ->
        []
    end
  end
end
