defmodule AcqdatCore.Test.Support.DataInsights.EntitiesHirerachyFactory do
  alias AcqdatCore.Model.EntityManagement.{Asset, Sensor}
  alias AcqdatCore.Schema.EntityManagement.Asset, as: AssetSchema
  import AcqdatCore.Support.Factory

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
    building_asset_type = insert(:asset_type, name: "Building")
    apartment_asset_type = insert(:asset_type, name: "Apartment")
    playground_asset_type = insert(:asset_type, name: "PlayGround")
    energy_mtr_sensor_type = insert(:sensor_type, name: "Energy Meter")
    temp_sensor_type = insert(:sensor_type, name: "Temp Sensor")
    occupancy_sensor_type = insert(:sensor_type, name: "Occupancy Sensor")
    user = insert(:user)

    building_1 =
      build_asset_map(
        "Building 1",
        org.id,
        org.name,
        project.id,
        user.id,
        building_asset_type.id,
        "Building"
      )

    building_2 =
      build_asset_map(
        "Building 2",
        org.id,
        org.name,
        project.id,
        user.id,
        building_asset_type.id,
        "Building"
      )

    building_3 =
      build_asset_map(
        "Building 3",
        org.id,
        org.name,
        project.id,
        user.id,
        building_asset_type.id,
        "Building"
      )

    apt_1_1 =
      build_asset_map(
        "Apartment 1.1",
        org.id,
        org.name,
        project.id,
        user.id,
        apartment_asset_type.id,
        "Apartment"
      )

    apt_1_2 =
      build_asset_map(
        "Apartment 1.2",
        org.id,
        org.name,
        project.id,
        user.id,
        apartment_asset_type.id,
        "Apartment"
      )

    playground_1 =
      build_asset_map(
        "PlayGround 1",
        org.id,
        org.name,
        project.id,
        user.id,
        playground_asset_type.id,
        "PlayGround"
      )

    apt_2_1 =
      build_asset_map(
        "Apartment 2.1",
        org.id,
        org.name,
        project.id,
        user.id,
        apartment_asset_type.id,
        "Apartment"
      )

    apt_2_2 =
      build_asset_map(
        "Apartment 2.2",
        org.id,
        org.name,
        project.id,
        user.id,
        apartment_asset_type.id,
        "Apartment"
      )

    apt_2_3 =
      build_asset_map(
        "Apartment 2.3",
        org.id,
        org.name,
        project.id,
        user.id,
        apartment_asset_type.id,
        "Apartment"
      )

    playground_2 =
      build_asset_map(
        "PlayGround 2",
        org.id,
        org.name,
        project.id,
        user.id,
        playground_asset_type.id,
        "PlayGround"
      )

    apt_3_1 =
      build_asset_map(
        "Apartment 3.1",
        org.id,
        org.name,
        project.id,
        user.id,
        apartment_asset_type.id,
        "Apartment"
      )

    apt_3_2 =
      build_asset_map(
        "Apartment 3.2",
        org.id,
        org.name,
        project.id,
        user.id,
        apartment_asset_type.id,
        "Apartment"
      )

    playground_3 =
      build_asset_map(
        "PlayGround 3",
        org.id,
        org.name,
        project.id,
        user.id,
        playground_asset_type.id,
        "PlayGround"
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

    {:ok, {org.id, project.id}}
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

  defp build_asset_map(name, org_id, _org_name, project_id, creator_id, asset_type_id, type) do
    %AssetSchema{
      name: name,
      org_id: org_id,
      project_id: project_id,
      creator_id: creator_id,
      asset_type_id: asset_type_id,
      mapped_parameters: [],
      owner_id: creator_id,
      properties: [],
      metadata: gen_asset_metadata(type)
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

  defp gen_asset_metadata(type) do
    case type do
      "Building" ->
        [
          %{
            name: "color",
            data_type: "string",
            unit: "",
            value: Enum.random(["white", "blue", "orange", "yellow", "pink"])
          },
          %{
            name: "date of constr",
            data_type: "date",
            unit: "date",
            value: "#{Date.utc_today()}"
          },
          %{
            name: "no of floors",
            data_type: "integer",
            unit: "",
            value: "#{Enum.random(1..10)}"
          }
        ]

      "Apartment" ->
        [
          %{
            name: "painted",
            data_type: "boolean",
            unit: "",
            value: "#{Enum.random([true, false])}"
          },
          %{
            name: "floor no",
            data_type: "integer",
            unit: "",
            value: "#{Enum.random(1..10)}"
          },
          %{
            name: "no of rooms",
            data_type: "integer",
            unit: "",
            value: "#{Enum.random(1..4)}"
          },
          %{
            name: "no of kids",
            data_type: "integer",
            unit: "",
            value: "#{Enum.random(0..4)}"
          },
          %{
            name: "ethnicity",
            data_type: "string",
            unit: "",
            value: "#{Enum.random(["American", "Indian", "African", "Korean", "Japanese"])}"
          }
        ]

      "PlayGround" ->
        [
          %{
            name: "painted",
            data_type: "boolean",
            unit: "",
            value: "#{Enum.random([true, false])}"
          },
          %{
            name: "no of instruments",
            data_type: "integer",
            unit: "",
            value: "#{Enum.random(2..10)}"
          }
        ]

      _ ->
        []
    end
  end
end
