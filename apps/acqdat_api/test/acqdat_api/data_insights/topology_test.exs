defmodule AcqdatApi.DataInsights.TopologyTest do
  use ExUnit.Case, async: false
  use AcqdatCore.DataCase
  alias AcqdatCore.Test.Support.DataInsights.EntitiesHirerachyFactory
  alias AcqdatApiWeb.DataInsights.Topology
  alias AcqdatCore.Model.EntityManagement.{Project, AssetType, SensorType}

  describe "gen_sub_topology/3" do
    setup do
      {:ok, {org_id, project_id}} = EntitiesHirerachyFactory.setup_tree()

      {:ok, project} = Project.get(project_id)

      [org_id: org_id, project: project]
    end

    test "returns sensor data, if user's input contains only one sensor_type(EnergyMtr)",
         context do
      %{org_id: org_id, project: project} = context

      user_list = [
        %{
          id: "2",
          name: "Energy Meter",
          type: "SensorType",
          metdata_name: "name",
          pos: 1
        }
      ]

      data = Topology.gen_sub_topology(org_id, project, user_list)

      assert data[:type] == "SensorType"
      assert data[:name] == "Energy Meter"
    end

    test "returns asset data, if user's input contains only one asset_type(Building)", context do
      %{org_id: org_id, project: project} = context

      user_list = [
        %{
          id: "1",
          name: "Building",
          type: "AssetType",
          metdata_name: "name",
          pos: 1
        }
      ]

      data = Topology.gen_sub_topology(org_id, project, user_list)

      assert data[:type] == "AssetType"
      assert data[:name] == "Building"
    end

    test "returns error, if user's input contains only sensor_types eg: [EnergyMtr, HeatMtr, OccSensor]",
         context do
      %{org_id: org_id, project: project} = context

      user_list = [
        %{
          id: "2",
          name: "Energy Meter",
          type: "SensorType",
          metdata_name: "name",
          pos: 1
        },
        %{
          id: "3",
          name: "Heat Meter",
          type: "SensorType",
          metdata_name: "name",
          pos: 2
        }
      ]

      {:error, err_msg} = Topology.gen_sub_topology(org_id, project, user_list)

      assert err_msg ==
               "Please attach parent asset_type as all the user-entities are of SensorTypes."
    end

    test "returns error, if user's input contains only asset_types, and all are on the same level eg: [Apartment, Playground]",
         context do
      %{org_id: org_id, project: project} = context

      {:ok, apartment_type} = AssetType.get(%{name: "Apartment"})
      {:ok, playground_type} = AssetType.get(%{name: "PlayGround"})

      user_list = [
        %{
          id: apartment_type.id,
          name: "Apartment",
          type: "AssetType",
          metdata_name: "name",
          pos: 1
        },
        %{
          id: playground_type.id,
          name: "PlayGround",
          type: "AssetType",
          metdata_name: "name",
          pos: 2
        }
      ]

      {:error, err_msg} = Topology.gen_sub_topology(org_id, project, user_list)

      assert err_msg ==
               "All the asset_type entities are at the same level, Please attach common parent entity."
    end

    test "returns error(Needs to attach common parent Building), if user input contains [Apartment, Playground, OccSensor]",
         context do
      %{org_id: org_id, project: project} = context

      {:ok, apartment_type} = AssetType.get(%{name: "Apartment"})
      {:ok, playground_type} = AssetType.get(%{name: "PlayGround"})
      {:ok, occ_sen_type} = SensorType.get(%{name: "Occupancy Sensor"})

      user_list = [
        %{
          id: apartment_type.id,
          name: "Apartment",
          type: "AssetType",
          metdata_name: "name",
          pos: 1
        },
        %{
          id: playground_type.id,
          name: "PlayGround",
          type: "AssetType",
          metdata_name: "name",
          pos: 2
        },
        %{
          id: occ_sen_type.id,
          name: "Occupancy Sensor",
          type: "SensorType",
          metdata_name: "name",
          pos: 3
        }
      ]

      {:error, err_msg} = Topology.gen_sub_topology(org_id, project, user_list)

      assert err_msg ==
               "All entities are not directly connected, please connect common parent entity."
    end

    test "returns error(Needs to attach common parent Building), if user input contains [Apartment, OccSensor]",
         context do
      %{org_id: org_id, project: project} = context

      {:ok, apartment_type} = AssetType.get(%{name: "Apartment"})
      {:ok, occ_sen_type} = SensorType.get(%{name: "Occupancy Sensor"})

      user_list = [
        %{
          id: apartment_type.id,
          name: "Apartment",
          type: "AssetType",
          metdata_name: "name",
          pos: 1
        },
        %{
          id: occ_sen_type.id,
          name: "Occupancy Sensor",
          type: "SensorType",
          metdata_name: "name",
          pos: 3
        }
      ]

      {:error, err_msg} = Topology.gen_sub_topology(org_id, project, user_list)

      assert err_msg ==
               "All entities are not directly connected, please connect common parent entity."
    end

    test "returns valid data, if the user provided input is a subtree of parent-entity tree like [Building, Apartment]",
         context do
      %{org_id: org_id, project: project} = context

      {:ok, apartment_type} = AssetType.get(%{name: "Apartment"})
      {:ok, building_type} = AssetType.get(%{name: "Building"})

      user_list = [
        %{
          id: building_type.id,
          name: "Building",
          type: "AssetType",
          metdata_name: "name",
          pos: 2
        },
        %{
          id: apartment_type.id,
          name: "Apartment",
          type: "AssetType",
          metdata_name: "name",
          pos: 1
        }
      ]

      res = Topology.gen_sub_topology(org_id, project, user_list)

      assert Map.has_key?(res, "Apartment")
      assert Map.has_key?(res, "Building")
      assert length(res["Apartment"]) != 0
      assert length(res["Building"]) != 0
    end

    test "returns valid data, if the user provided input is a subtree of parent-entity tree like [Building, Apartment, EnergyMtr]",
         context do
      %{org_id: org_id, project: project} = context

      {:ok, apartment_type} = AssetType.get(%{name: "Apartment"})
      {:ok, building_type} = AssetType.get(%{name: "Building"})
      {:ok, energy_mtr_type} = SensorType.get(%{name: "Energy Meter"})

      user_list = [
        %{
          id: building_type.id,
          name: "Building",
          type: "AssetType",
          metdata_name: "name",
          pos: 2
        },
        %{
          id: apartment_type.id,
          name: "Apartment",
          type: "AssetType",
          metdata_name: "name",
          pos: 3
        },
        %{
          id: energy_mtr_type.id,
          name: "Energy Meter",
          type: "SensorType",
          metdata_name: "name",
          pos: 1
        }
      ]

      res = Topology.gen_sub_topology(org_id, project, user_list)

      assert Map.has_key?(res, "Apartment")
      assert Map.has_key?(res, "Building")
      assert Map.has_key?(res, "Energy Meter")
      assert length(res["Apartment"]) != 0
      assert length(res["Building"]) != 0
      assert length(res["Energy Meter"]) != 0
    end
  end
end
