defmodule AcqdatApi.DataInsights.FactTablesTest do
  use ExUnit.Case, async: false
  use AcqdatCore.DataCase
  alias AcqdatCore.Test.Support.DataInsights.EntitiesHirerachyFactory
  alias AcqdatCore.Model.EntityManagement.{Project, AssetType, SensorType}
  import AcqdatCore.Support.Factory
  alias NaryTree
  alias AcqdatApi.DataInsights.Topology
  alias AcqdatApi.DataInsights.FactTables, as: FactTableCon

  describe "gen_sub_topology/3" do
    setup do
      {:ok, {org_id, project_id}} = EntitiesHirerachyFactory.setup_tree()

      {:ok, project} = Project.get(project_id)

      {:ok, apartment_type} = AssetType.get(%{name: "Apartment"})
      {:ok, playground_type} = AssetType.get(%{name: "PlayGround"})
      {:ok, building_type} = AssetType.get(%{name: "Building"})
      {:ok, place_type} = AssetType.get(%{name: "Place"})
      {:ok, occupancy_sensor_type} = SensorType.get(%{name: "Occupancy Sensor"})
      {:ok, energy_mtr_type} = SensorType.get(%{name: "Energy Meter"})
      {:ok, temp_mtr_type} = SensorType.get(%{name: "Temp Sensor"})
      fact_table = insert(:fact_tables)

      [
        org_id: org_id,
        project: project,
        apartment_type: apartment_type,
        playground_type: playground_type,
        building_type: building_type,
        place_type: place_type,
        occupancy_sensor_type: occupancy_sensor_type,
        energy_mtr_type: energy_mtr_type,
        temp_mtr_type: temp_mtr_type,
        fact_table: fact_table
      ]
    end

    test "returns sensor data, if user's input contains only one sensor_type(EnergyMtr)",
         context do
      %{
        energy_mtr_type: energy_mtr_type,
        fact_table: fact_table
      } = context

      user_list = [
        %{
          "id" => energy_mtr_type.id,
          "name" => "Energy Meter",
          "type" => "SensorType",
          "metadata_name" => "name",
          "metadata_id" => "name",
          "pos" => 1
        }
      ]

      res =
        FactTableCon.gen_comp_sensor_data(%{fact_table_id: fact_table.id, sensor_types: user_list})

      assert res.total == 6

      assert res.headers == [%{"Energy Meter" => "text"}]
    end

    test "returns sensor data with timestamp, if user's input contains only one sensor_type(EnergyMtr) with metadata",
         context do
      %{
        energy_mtr_type: energy_mtr_type,
        fact_table: fact_table
      } = context

      current_param =
        Enum.find(energy_mtr_type.parameters, fn parameter -> parameter.name == "Current" end)

      user_list = [
        %{
          "id" => energy_mtr_type.id,
          "name" => "Energy Meter",
          "type" => "SensorType",
          "metadata_name" => "Current",
          "metadata_id" => current_param.uuid,
          "pos" => 1,
          "date_from" =>
            "#{Timex.shift(Timex.now(), months: -1) |> DateTime.to_unix(:millisecond)}",
          "date_to" => "#{Timex.now() |> DateTime.to_unix(:millisecond)}"
        }
      ]

      res =
        FactTableCon.gen_comp_sensor_data(%{fact_table_id: fact_table.id, sensor_types: user_list})

      assert res.total == 78

      assert res.headers == [
               %{"Energy Meter Current" => "numeric"},
               %{"Energy Meter Current_dateTime" => "timestamp without time zone"}
             ]
    end

    test "returns asset data, if user's input contains only one asset_type(Building)", context do
      %{building_type: building_type, fact_table: fact_table} = context

      user_list = [
        %{
          "id" => building_type.id,
          "name" => "Building",
          "type" => "AssetType",
          "metadata_name" => "name",
          "metadata_id" => "name",
          "pos" => 1
        }
      ]

      res =
        FactTableCon.gen_comp_asset_data(%{fact_table_id: fact_table.id, asset_types: user_list})

      assert res.total == 3

      assert res.headers == [%{"name" => "text"}]
    end

    test "returns asset data, if user's input contains only one asset_type(Building) metadata",
         context do
      %{building_type: building_type, fact_table: fact_table} = context

      color_param =
        Enum.find(building_type.metadata, fn parameter -> parameter.name == "color" end)

      user_list = [
        %{
          "id" => building_type.id,
          "name" => "Building",
          "type" => "AssetType",
          "metadata_name" => "color",
          "metadata_id" => color_param.uuid,
          "pos" => 1
        }
      ]

      res =
        FactTableCon.gen_comp_asset_data(%{fact_table_id: fact_table.id, asset_types: user_list})

      assert res.total == 3

      assert res.headers == [%{"color" => "text"}]
    end

    test "returns asset data, if user's input contains only one asset_type(Building) multiple metadata",
         context do
      %{building_type: building_type, fact_table: fact_table} = context

      color_param =
        Enum.find(building_type.metadata, fn parameter -> parameter.name == "color" end)

      user_list = [
        %{
          "id" => building_type.id,
          "name" => "Building",
          "type" => "AssetType",
          "metadata_name" => "color",
          "metadata_id" => color_param.uuid,
          "pos" => 1
        },
        %{
          "id" => building_type.id,
          "name" => "Building",
          "type" => "AssetType",
          "metadata_name" => "name",
          "metadata_id" => "name",
          "pos" => 2
        }
      ]

      uniq_asset_types = [
        %{
          "id" => building_type.id,
          "name" => "Building",
          "type" => "AssetType",
          "metadata_name" => "name",
          "metadata_id" => "name",
          "pos" => 2
        }
      ]

      res =
        FactTableCon.gen_comp_asset_metadata(%{
          fact_table_id: fact_table.id,
          asset_types: user_list,
          uniq_asset_types: uniq_asset_types
        })

      assert res.total == 3

      assert res.headers == [%{"name" => "text"}, %{"color" => "text"}]
    end

    test "should return valid data, if the user provided input is a subtree of parent-entity tree like [Building, Apartment]",
         context do
      %{
        org_id: org_id,
        project: project,
        apartment_type: apartment_type,
        building_type: building_type,
        fact_table: fact_table
      } = context

      user_list = [
        %{
          "id" => building_type.id,
          "name" => "Building",
          "type" => "AssetType",
          "metadata_name" => "name",
          "metadata_id" => "name",
          "pos" => 2
        },
        %{
          "id" => apartment_type.id,
          "name" => "Apartment",
          "type" => "AssetType",
          "metadata_name" => "name",
          "metadata_id" => "name",
          "pos" => 1
        }
      ]

      res = gen_n_compute_fact_table(org_id, project, user_list, fact_table.id)

      assert res.total == 7

      assert Enum.sort(res.headers) == [
               %{"Apartment name" => "text"},
               %{"Building name" => "text"}
             ]
    end

    test "should return valid data, if the user provided input is a subtree of parent-entity tree like [Building, Apartment, EnergyMtr]",
         context do
      %{
        org_id: org_id,
        project: project,
        apartment_type: apartment_type,
        building_type: building_type,
        energy_mtr_type: energy_mtr_type,
        fact_table: fact_table
      } = context

      user_list = [
        %{
          "id" => building_type.id,
          "name" => "Building",
          "type" => "AssetType",
          "metadata_name" => "name",
          "metadata_id" => "name",
          "pos" => 2
        },
        %{
          "id" => apartment_type.id,
          "name" => "Apartment",
          "type" => "AssetType",
          "metadata_name" => "name",
          "metadata_id" => "name",
          "pos" => 3
        },
        %{
          "id" => energy_mtr_type.id,
          "name" => "Energy Meter",
          "type" => "SensorType",
          "metadata_name" => "name",
          "metadata_id" => "name",
          "pos" => 1
        }
      ]

      res = gen_n_compute_fact_table(org_id, project, user_list, fact_table.id)

      assert res.total == 7

      assert Enum.sort(res.headers) == [
               %{"Apartment name" => "text"},
               %{"Building name" => "text"},
               %{"Energy Meter name" => "text"}
             ]
    end

    test "should return valid data, if the user provided entities like this [Place, Apartment]",
         context do
      %{
        org_id: org_id,
        project: project,
        apartment_type: apartment_type,
        place_type: place_type,
        fact_table: fact_table
      } = context

      user_list = [
        %{
          "id" => apartment_type.id,
          "name" => "Apartment",
          "type" => "AssetType",
          "metadata_name" => "name",
          "metadata_id" => "name",
          "pos" => 2
        },
        %{
          "id" => place_type.id,
          "name" => "Place",
          "type" => "AssetType",
          "metadata_name" => "name",
          "metadata_id" => "name",
          "pos" => 1
        }
      ]

      res = gen_n_compute_fact_table(org_id, project, user_list, fact_table.id)

      assert res.total == 7
      assert Enum.sort(res.headers) == [%{"Apartment name" => "text"}, %{"Place name" => "text"}]
    end

    test "should return valid data, if the user provided input with two siblings and one parent like [Building, Apartment, Playground]",
         context do
      %{
        org_id: org_id,
        project: project,
        apartment_type: apartment_type,
        building_type: building_type,
        playground_type: playground_type,
        fact_table: fact_table
      } = context

      user_list = [
        %{
          "id" => building_type.id,
          "name" => "Building",
          "type" => "AssetType",
          "metadata_name" => "name",
          "metadata_id" => "name",
          "pos" => 2
        },
        %{
          "id" => apartment_type.id,
          "name" => "Apartment",
          "type" => "AssetType",
          "metadata_name" => "name",
          "metadata_id" => "name",
          "pos" => 3
        },
        %{
          "id" => playground_type.id,
          "name" => "PlayGround",
          "type" => "AssetType",
          "metadata_name" => "name",
          "metadata_id" => "name",
          "pos" => 1
        }
      ]

      res = gen_n_compute_fact_table(org_id, project, user_list, fact_table.id)

      assert res.total == 10

      assert Enum.sort(res.headers) == [
               %{"Apartment name" => "text"},
               %{"Building name" => "text"},
               %{"PlayGround name" => "text"}
             ]

      assert length(res.data) == 10
    end

    test "should return error, if there is no data for this combination [Place, EnergyMtr]",
         context do
      %{
        org_id: org_id,
        project: project,
        place_type: place_type,
        energy_mtr_type: energy_mtr_type,
        fact_table: fact_table
      } = context

      user_list = [
        %{
          "id" => place_type.id,
          "name" => "Place",
          "type" => "AssetType",
          "metadata_name" => "name",
          "metadata_id" => "name",
          "pos" => 2
        },
        %{
          "id" => energy_mtr_type.id,
          "name" => "Energy Meter",
          "type" => "SensorType",
          "metadata_name" => "name",
          "metadata_id" => "name",
          "date_from" =>
            "#{Timex.shift(Timex.now(), months: -1) |> DateTime.to_unix(:millisecond)}",
          "date_to" => "#{Timex.now() |> DateTime.to_unix(:millisecond)}",
          "pos" => 1
        }
      ]

      res = gen_n_compute_fact_table(org_id, project, user_list, fact_table.id)

      assert res[:error] == "No data present for the specified user inputs"
    end

    test "should return error, if there is no data for this combination [Place, OccupancySensor]",
         context do
      %{
        org_id: org_id,
        project: project,
        place_type: place_type,
        occupancy_sensor_type: occupancy_sensor_type,
        fact_table: fact_table
      } = context

      user_list = [
        %{
          "id" => place_type.id,
          "name" => "Place",
          "type" => "AssetType",
          "metadata_name" => "name",
          "pos" => 2
        },
        %{
          "id" => occupancy_sensor_type.id,
          "name" => "Occupancy Sensor",
          "type" => "SensorType",
          "metadata_name" => "name",
          "metadata_id" => "name",
          "date_from" =>
            "#{Timex.shift(Timex.now(), months: -1) |> DateTime.to_unix(:millisecond)}",
          "date_to" => "#{Timex.now() |> DateTime.to_unix(:millisecond)}",
          "pos" => 1
        }
      ]

      res = gen_n_compute_fact_table(org_id, project, user_list, fact_table.id)

      assert res[:error] == "No data present for the specified user inputs"
    end

    test "should return data, if the user provided entities are like this [Building, Apartment, OccupancySensor]",
         context do
      %{
        org_id: org_id,
        project: project,
        apartment_type: apartment_type,
        building_type: building_type,
        occupancy_sensor_type: occupancy_sensor_type,
        fact_table: fact_table
      } = context

      painted_param =
        Enum.find(apartment_type.metadata, fn parameter -> parameter.name == "painted" end)

      color_param =
        Enum.find(building_type.metadata, fn parameter -> parameter.name == "color" end)

      user_list = [
        %{
          "id" => apartment_type.id,
          "name" => "Apartment",
          "type" => "AssetType",
          "metadata_name" => "name",
          "metadata_id" => "name",
          "pos" => 2
        },
        %{
          "id" => apartment_type.id,
          "name" => "Apartment",
          "type" => "AssetType",
          "metadata_name" => "painted",
          "metadata_id" => painted_param.uuid,
          "pos" => 4
        },
        %{
          "id" => building_type.id,
          "name" => "Building",
          "type" => "AssetType",
          "metadata_id" => "name",
          "metadata_name" => "name",
          "pos" => 3
        },
        %{
          "id" => building_type.id,
          "name" => "Building",
          "type" => "AssetType",
          "metadata_id" => color_param.uuid,
          "metadata_name" => "color",
          "pos" => 5
        },
        %{
          "id" => occupancy_sensor_type.id,
          "name" => "Occupancy Sensor",
          "type" => "SensorType",
          "metadata_name" => "name",
          "metadata_id" => "name",
          "date_from" =>
            "#{Timex.shift(Timex.now(), months: -1) |> DateTime.to_unix(:millisecond)}",
          "date_to" => "#{Timex.now() |> DateTime.to_unix(:millisecond)}",
          "pos" => 1
        }
      ]

      res = gen_n_compute_fact_table(org_id, project, user_list, fact_table.id)

      assert res.total == 7

      assert Enum.sort(res.headers) ==
               Enum.sort([
                 %{"Apartment name" => "text"},
                 %{"Apartment painted" => "text"},
                 %{"Building color" => "text"},
                 %{"Building name" => "text"},
                 %{"Occupancy Sensor name" => "text"}
               ])

      assert length(res.data) == 7
    end

    test "should return data, if the user provided entities are like this [Building, Place, Apartment, OccupancySensor, EnergyMtr]",
         context do
      %{
        org_id: org_id,
        project: project,
        apartment_type: apartment_type,
        building_type: building_type,
        occupancy_sensor_type: occupancy_sensor_type,
        place_type: place_type,
        energy_mtr_type: energy_mtr_type,
        fact_table: fact_table
      } = context

      painted_param =
        Enum.find(apartment_type.metadata, fn parameter -> parameter.name == "painted" end)

      color_param =
        Enum.find(building_type.metadata, fn parameter -> parameter.name == "color" end)

      user_list = [
        %{
          "id" => apartment_type.id,
          "name" => "Apartment",
          "type" => "AssetType",
          "metadata_name" => "name",
          "metadata_id" => "name",
          "pos" => 2
        },
        %{
          "id" => apartment_type.id,
          "name" => "Apartment",
          "type" => "AssetType",
          "metadata_name" => "painted",
          "metadata_id" => painted_param.uuid,
          "pos" => 4
        },
        %{
          "id" => building_type.id,
          "name" => "Building",
          "type" => "AssetType",
          "metadata_id" => "name",
          "metadata_name" => "name",
          "pos" => 3
        },
        %{
          "id" => building_type.id,
          "name" => "Building",
          "type" => "AssetType",
          "metadata_name" => "color",
          "metadata_id" => color_param.uuid,
          "pos" => 5
        },
        %{
          "id" => occupancy_sensor_type.id,
          "name" => "Occupancy Sensor",
          "type" => "SensorType",
          "metadata_name" => "name",
          "metadata_id" => "name",
          "date_from" =>
            "#{Timex.shift(Timex.now(), months: -1) |> DateTime.to_unix(:millisecond)}",
          "date_to" => "#{Timex.now() |> DateTime.to_unix(:millisecond)}",
          "pos" => 1
        },
        %{
          "id" => place_type.id,
          "name" => "Place",
          "type" => "AssetType",
          "metadata_name" => "name",
          "metadata_id" => "name",
          "pos" => 2
        },
        %{
          "id" => energy_mtr_type.id,
          "name" => "Energy Meter",
          "type" => "SensorType",
          "metadata_name" => "name",
          "metadata_id" => "name",
          "date_from" =>
            "#{Timex.shift(Timex.now(), months: -1) |> DateTime.to_unix(:millisecond)}",
          "date_to" => "#{Timex.now() |> DateTime.to_unix(:millisecond)}",
          "pos" => 1
        }
      ]

      res = gen_n_compute_fact_table(org_id, project, user_list, fact_table.id)

      assert res.total == 7

      assert Enum.sort(res.headers) ==
               Enum.sort([
                 %{"Apartment name" => "text"},
                 %{"Apartment painted" => "text"},
                 %{"Building color" => "text"},
                 %{"Building name" => "text"},
                 %{"Energy Meter name" => "text"},
                 %{"Occupancy Sensor name" => "text"},
                 %{"Place name" => "text"}
               ])

      assert length(res.data) == 7
    end

    test "should return data, if the user provided entities contains sensors telemetry data",
         context do
      %{
        org_id: org_id,
        project: project,
        apartment_type: apartment_type,
        energy_mtr_type: energy_mtr_type,
        fact_table: fact_table
      } = context

      current_param =
        Enum.find(energy_mtr_type.parameters, fn parameter -> parameter.name == "Current" end)

      user_list = [
        %{
          "id" => energy_mtr_type.id,
          "name" => "Energy Meter",
          "type" => "SensorType",
          "metadata_name" => "Current",
          "metadata_id" => current_param.uuid,
          "date_from" =>
            "#{Timex.shift(Timex.now(), months: -1) |> DateTime.to_unix(:millisecond)}",
          "date_to" => "#{Timex.now() |> DateTime.to_unix(:millisecond)}",
          "pos" => 1
        },
        %{
          "id" => apartment_type.id,
          "name" => "Apartment",
          "type" => "AssetType",
          "metadata_id" => "name",
          "metadata_name" => "name",
          "pos" => 2
        }
      ]

      res = gen_n_compute_fact_table(org_id, project, user_list, fact_table.id)

      assert res.total == 78

      assert Enum.sort(res.headers) ==
               Enum.sort([
                 %{"Apartment name" => "text"},
                 %{"Energy Meter Current" => "numeric"},
                 %{"Energy Meter Current_dateTime" => "timestamp without time zone"}
               ])

      assert length(res.data) == 20
    end

    test "returns sensor data with timestamp, if user's input contains only a sensor_type(EnergyMtr) with metadata",
         context do
      %{
        energy_mtr_type: energy_mtr_type,
        fact_table: fact_table
      } = context

      current_param =
        Enum.find(energy_mtr_type.parameters, fn parameter -> parameter.name == "Current" end)

      energy_param =
        Enum.find(energy_mtr_type.parameters, fn parameter -> parameter.name == "Energy" end)

      voltage_param =
        Enum.find(energy_mtr_type.parameters, fn parameter -> parameter.name == "Voltage" end)

      user_list = [
        %{
          "id" => energy_mtr_type.id,
          "name" => "Energy Meter",
          "type" => "SensorType",
          "metadata_name" => "Current",
          "metadata_id" => current_param.uuid,
          "date_from" =>
            "#{Timex.shift(Timex.now(), months: -1) |> DateTime.to_unix(:millisecond)}",
          "date_to" => "#{Timex.now() |> DateTime.to_unix(:millisecond)}",
          "pos" => 1
        },
        %{
          "id" => energy_mtr_type.id,
          "name" => "Energy Meter",
          "type" => "SensorType",
          "metadata_name" => "Energy",
          "metadata_id" => energy_param.uuid,
          "date_from" =>
            "#{Timex.shift(Timex.now(), months: -1) |> DateTime.to_unix(:millisecond)}",
          "date_to" => "#{Timex.now() |> DateTime.to_unix(:millisecond)}",
          "pos" => 1
        },
        %{
          "id" => energy_mtr_type.id,
          "name" => "Energy Meter",
          "type" => "SensorType",
          "metadata_name" => "Voltage",
          "metadata_id" => voltage_param.uuid,
          "date_from" =>
            "#{Timex.shift(Timex.now(), months: -1) |> DateTime.to_unix(:millisecond)}",
          "date_to" => "#{Timex.now() |> DateTime.to_unix(:millisecond)}",
          "pos" => 1
        }
      ]

      uniq_sensor_types = Enum.uniq_by(user_list, fn sensor_type -> sensor_type["id"] end)

      res =
        FactTableCon.compute_sensors(
          fact_table.id,
          user_list,
          uniq_sensor_types
        )

      assert res.total != 0

      assert Enum.sort(res.headers) ==
               Enum.sort([
                 %{"Current" => "numeric"},
                 %{"Energy" => "numeric"},
                 %{"Voltage" => "numeric"},
                 %{"entity_dateTime" => "timestamp without time zone"}
               ])
    end

    defp gen_n_compute_fact_table(org_id, project, user_list, fact_table_id) do
      topology_map = Topology.gen_topology(org_id, project)
      parent_tree = NaryTree.from_map(topology_map)

      {_entity_levels, {root_node, root_entity}, entity_map} =
        Enum.reduce(user_list, {[], {nil, nil}, %{}}, fn entity, {acc1, {acc2, acc4}, acc3} ->
          node = NaryTree.get(parent_tree, "#{entity["id"]}")
          acc1 = acc1 ++ [node.level]

          {acc2, acc4} =
            if acc2 != nil && acc2.level < node.level, do: {acc2, acc4}, else: {node, entity}

          acc3 = Map.put_new(acc3, "#{entity["type"]}_#{entity["id"]}", false)
          {acc1, {acc2, acc4}, acc3}
        end)

      node_tracker = Map.put(entity_map, "#{root_entity["type"]}_#{root_entity["id"]}", true)

      FactTableCon.fetch_descendants(
        fact_table_id,
        parent_tree,
        root_node,
        user_list,
        node_tracker
      )
    end
  end
end
