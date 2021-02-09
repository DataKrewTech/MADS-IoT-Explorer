defmodule AcqdatApi.DataInsights.TopologyTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  alias AcqdatCore.Test.Support.DataInsights.EntitiesHirerachyFactory
  alias AcqdatApi.DataInsights.Topology
  alias AcqdatCore.Model.EntityManagement.{Project, AssetType, SensorType}
  import AcqdatCore.Support.Factory

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
        org_id: org_id,
        project: project,
        energy_mtr_type: energy_mtr_type,
        fact_table: fact_table
      } = context

      user_list = [
        %{
          "id" => energy_mtr_type.id,
          "name" => "Energy Meter",
          "type" => "SensorType",
          "metadata_name" => "name",
          "pos" => 1
        }
      ]

      Topology.gen_sub_topology(
        fact_table.id,
        org_id,
        project,
        "fact table 1.1",
        fact_table,
        user_list,
        %{}
      )

      query = "SELECT * FROM fact_table_#{fact_table.id}"

      data = Ecto.Adapters.SQL.query!(Repo, query, [])

      assert data.num_rows == 6
    end

    # test "returns sensor data with timestamp, if user's input contains only one sensor_type(EnergyMtr) with metadata",
    #      context do
    #   %{org_id: org_id, project: project, energy_mtr_type: energy_mtr_type, fact_table: fact_table} = context

    #   user_list = [
    #     %{
    #       "id" => energy_mtr_type.id,
    #       "name" => "Energy Meter",
    #       "type" => "SensorType",
    #       "metadata_name" => "Current",
    #       "date_from" => "#{Timex.shift(Timex.now(), months: -1) |> DateTime.to_unix(:millisecond)}",
    #       "date_to" => "#{Timex.now() |> DateTime.to_unix(:millisecond)}",
    #       "pos" => 1
    #     }
    #   ]

    #   Topology.gen_sub_topology(fact_table.id, org_id, project, "fact table 1.1", fact_table, user_list, %{})

    #   # assert Map.has_key?(data, "Energy Meter")
    #   # assert length(data["Energy Meter"]) != 0
    # end

    test "returns asset data, if user's input contains only one asset_type(Building)", context do
      %{org_id: org_id, project: project, building_type: building_type, fact_table: fact_table} =
        context

      user_list = [
        %{
          "id" => building_type.id,
          "name" => "Building",
          "type" => "AssetType",
          "metadata_name" => "name",
          "pos" => 1
        }
      ]

      Topology.gen_sub_topology(
        fact_table.id,
        org_id,
        project,
        "fact table 1.1",
        fact_table,
        user_list,
        %{}
      )

      query = "SELECT * FROM fact_table_#{fact_table.id}"

      data = Ecto.Adapters.SQL.query!(Repo, query, [])

      assert data.num_rows == 3
    end

    test "returns error and temp table will not be created, if user's input contains only sensor_types eg: [EnergyMtr, HeatMtr, OccSensor]",
         context do
      %{org_id: org_id, project: project, fact_table: fact_table} = context

      user_list = [
        %{
          "id" => "2",
          "name" => "Energy Meter",
          "type" => "SensorType",
          "metadata_name" => "name",
          "pos" => 1
        },
        %{
          "id" => "3",
          "name" => "Heat Meter",
          "type" => "SensorType",
          "metadata_name" => "name",
          "pos" => 2
        }
      ]

      Topology.gen_sub_topology(
        fact_table.id,
        org_id,
        project,
        "fact table 1.1",
        fact_table,
        user_list,
        %{}
      )

      query = "SELECT EXISTS (
         SELECT FROM information_schema.tables 
         WHERE table_name   = 'fact_table_#{fact_table.id}'
         )"

      data = Ecto.Adapters.SQL.query!(Repo, query, [])

      [[table_exists?]] = data.rows

      assert table_exists? == false
    end

    test "returns error and temp table will not be created, if user's input contains only asset_types, and all are on the same level eg: [Apartment, Playground]",
         context do
      %{
        org_id: org_id,
        project: project,
        apartment_type: apartment_type,
        playground_type: playground_type,
        fact_table: fact_table
      } = context

      user_list = [
        %{
          "id" => apartment_type.id,
          "name" => "Apartment",
          "type" => "AssetType",
          "metadata_name" => "name",
          "pos" => 1
        },
        %{
          "id" => playground_type.id,
          "name" => "PlayGround",
          "type" => "AssetType",
          "metadata_name" => "name",
          "pos" => 2
        }
      ]

      Topology.gen_sub_topology(
        fact_table.id,
        org_id,
        project,
        "fact table 1.1",
        fact_table,
        user_list,
        %{}
      )

      query = "SELECT EXISTS (
         SELECT FROM information_schema.tables 
         WHERE table_name   = 'fact_table_#{fact_table.id}'
         )"

      data = Ecto.Adapters.SQL.query!(Repo, query, [])

      [[table_exists?]] = data.rows

      assert table_exists? == false
    end

    test "returns error(Needs to attach common parent Building) and temp table will not be created, if user input contains [Apartment, Playground, OccSensor]",
         context do
      %{
        org_id: org_id,
        project: project,
        apartment_type: apartment_type,
        playground_type: playground_type,
        occupancy_sensor_type: occupancy_sensor_type,
        fact_table: fact_table
      } = context

      user_list = [
        %{
          "id" => apartment_type.id,
          "name" => "Apartment",
          "type" => "AssetType",
          "metadata_name" => "name",
          "pos" => 1
        },
        %{
          "id" => playground_type.id,
          "name" => "PlayGround",
          "type" => "AssetType",
          "metadata_name" => "name",
          "pos" => 2
        },
        %{
          "id" => occupancy_sensor_type.id,
          "name" => "Occupancy Sensor",
          "type" => "SensorType",
          "metadata_name" => "name",
          "pos" => 3
        }
      ]

      Topology.gen_sub_topology(
        fact_table.id,
        org_id,
        project,
        "fact table 1.1",
        fact_table,
        user_list,
        %{}
      )

      query = "SELECT EXISTS (
         SELECT FROM information_schema.tables 
         WHERE table_name   = 'fact_table_#{fact_table.id}'
         )"

      data = Ecto.Adapters.SQL.query!(Repo, query, [])

      [[table_exists?]] = data.rows

      assert table_exists? == false
    end

    test "returns error(Needs to attach common parent Building) and temp table will not be created, if user input contains [Apartment, OccSensor]",
         context do
      %{
        org_id: org_id,
        project: project,
        apartment_type: apartment_type,
        occupancy_sensor_type: occupancy_sensor_type,
        fact_table: fact_table
      } = context

      user_list = [
        %{
          "id" => apartment_type.id,
          "name" => "Apartment",
          "type" => "AssetType",
          "metadata_name" => "name",
          "pos" => 1
        },
        %{
          "id" => occupancy_sensor_type.id,
          "name" => "Occupancy Sensor",
          "type" => "SensorType",
          "metadata_name" => "name",
          "pos" => 3
        }
      ]

      Topology.gen_sub_topology(
        fact_table.id,
        org_id,
        project,
        "fact table 1.1",
        fact_table,
        user_list,
        %{}
      )

      query = "SELECT EXISTS (
         SELECT FROM information_schema.tables 
         WHERE table_name   = 'fact_table_#{fact_table.id}'
         )"

      data = Ecto.Adapters.SQL.query!(Repo, query, [])

      [[table_exists?]] = data.rows

      assert table_exists? == false
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
          "pos" => 2
        },
        %{
          "id" => apartment_type.id,
          "name" => "Apartment",
          "type" => "AssetType",
          "metadata_name" => "name",
          "pos" => 1
        }
      ]

      {:ok, _} =
        Topology.gen_sub_topology(
          fact_table.id,
          org_id,
          project,
          "fact table 1.1",
          fact_table,
          user_list,
          %{}
        )
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
          "pos" => 2
        },
        %{
          "id" => apartment_type.id,
          "name" => "Apartment",
          "type" => "AssetType",
          "metadata_name" => "name",
          "pos" => 3
        },
        %{
          "id" => energy_mtr_type.id,
          "name" => "Energy Meter",
          "type" => "SensorType",
          "metadata_name" => "name",
          "pos" => 1
        }
      ]

      {:ok, _} =
        Topology.gen_sub_topology(
          fact_table.id,
          org_id,
          project,
          "fact table 1.1",
          fact_table,
          user_list,
          %{}
        )
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
          "pos" => 2
        },
        %{
          "id" => place_type.id,
          "name" => "Place",
          "type" => "AssetType",
          "metadata_name" => "name",
          "pos" => 1
        }
      ]

      {:ok, _} =
        Topology.gen_sub_topology(
          fact_table.id,
          org_id,
          project,
          "fact table 1.1",
          fact_table,
          user_list,
          %{}
        )
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
          "pos" => 2
        },
        %{
          "id" => apartment_type.id,
          "name" => "Apartment",
          "type" => "AssetType",
          "metadata_name" => "name",
          "pos" => 3
        },
        %{
          "id" => playground_type.id,
          "name" => "PlayGround",
          "type" => "AssetType",
          "metadata_name" => "name",
          "pos" => 1
        }
      ]

      {:ok, _} =
        Topology.gen_sub_topology(
          fact_table.id,
          org_id,
          project,
          "fact table 1.1",
          fact_table,
          user_list,
          %{}
        )
    end

    test "should return valid data, if the user provided entities are not directly connected, like this [Building, EnergyMtr]",
         context do
      %{
        org_id: org_id,
        project: project,
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
          "pos" => 2
        },
        %{
          "id" => energy_mtr_type.id,
          "name" => "Energy Meter",
          "type" => "SensorType",
          "metadata_name" => "name",
          "pos" => 1
        }
      ]

      {:ok, _} =
        Topology.gen_sub_topology(
          fact_table.id,
          org_id,
          project,
          "fact table 1.1",
          fact_table,
          user_list,
          %{}
        )
    end

    test "should return valid data, if the user provided entities are like this [Place, EnergyMtr]",
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
          "pos" => 2
        },
        %{
          "id" => energy_mtr_type.id,
          "name" => "Energy Meter",
          "type" => "SensorType",
          "metadata_name" => "name",
          "pos" => 1
        }
      ]

      {:ok, _} =
        Topology.gen_sub_topology(
          fact_table.id,
          org_id,
          project,
          "fact table 1.1",
          fact_table,
          user_list,
          %{}
        )
    end

    test "should return valid data, if the user provided entities are like this [Place, OccupancySensor]",
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
          "pos" => 1
        }
      ]

      {:ok, _} =
        Topology.gen_sub_topology(
          fact_table.id,
          org_id,
          project,
          "fact table 1.1",
          fact_table,
          user_list,
          %{}
        )
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

      user_list = [
        %{
          "id" => apartment_type.id,
          "name" => "Apartment",
          "type" => "AssetType",
          "metadata_name" => "name",
          "pos" => 2
        },
        %{
          "id" => apartment_type.id,
          "name" => "Apartment",
          "type" => "AssetType",
          "metadata_name" => "painted",
          "pos" => 4
        },
        %{
          "id" => building_type.id,
          "name" => "Building",
          "type" => "AssetType",
          "metadata_name" => "name",
          "pos" => 3
        },
        %{
          "id" => building_type.id,
          "name" => "Building",
          "type" => "AssetType",
          "metadata_name" => "color",
          "pos" => 5
        },
        %{
          "id" => occupancy_sensor_type.id,
          "name" => "Occupancy Sensor",
          "type" => "SensorType",
          "metadata_name" => "name",
          "pos" => 1
        }
      ]

      {:ok, _} =
        Topology.gen_sub_topology(
          fact_table.id,
          org_id,
          project,
          "fact table 1.1",
          fact_table,
          user_list,
          %{}
        )
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

      user_list = [
        %{
          "id" => apartment_type.id,
          "name" => "Apartment",
          "type" => "AssetType",
          "metadata_name" => "name",
          "pos" => 2
        },
        %{
          "id" => apartment_type.id,
          "name" => "Apartment",
          "type" => "AssetType",
          "metadata_name" => "painted",
          "pos" => 4
        },
        %{
          "id" => building_type.id,
          "name" => "Building",
          "type" => "AssetType",
          "metadata_name" => "name",
          "pos" => 3
        },
        %{
          "id" => building_type.id,
          "name" => "Building",
          "type" => "AssetType",
          "metadata_name" => "color",
          "pos" => 5
        },
        %{
          "id" => occupancy_sensor_type.id,
          "name" => "Occupancy Sensor",
          "type" => "SensorType",
          "metadata_name" => "name",
          "pos" => 1
        },
        %{
          "id" => place_type.id,
          "name" => "Place",
          "type" => "AssetType",
          "metadata_name" => "name",
          "pos" => 2
        },
        %{
          "id" => energy_mtr_type.id,
          "name" => "Energy Meter",
          "type" => "SensorType",
          "metadata_name" => "name",
          "pos" => 1
        }
      ]

      {:ok, _} =
        Topology.gen_sub_topology(
          fact_table.id,
          org_id,
          project,
          "fact table 1.1",
          fact_table,
          user_list,
          %{}
        )
    end

    test "should return error, if the user provided entities are like this [Place, Temp Sensor]",
         context do
      %{
        org_id: org_id,
        project: project,
        place_type: apartment_type,
        temp_mtr_type: temp_mtr_type,
        fact_table: fact_table
      } = context

      user_list = [
        %{
          "id" => apartment_type.id,
          "name" => "Place",
          "type" => "AssetType",
          "metadata_name" => "name",
          "pos" => 2
        },
        %{
          "id" => temp_mtr_type.id,
          "name" => "Temp Sensor",
          "type" => "SensorType",
          "metadata_name" => "name",
          "pos" => 1
        }
      ]

      {:ok, _} =
        Topology.gen_sub_topology(
          fact_table.id,
          org_id,
          project,
          "fact table 1.1",
          fact_table,
          user_list,
          %{}
        )
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

      user_list = [
        %{
          "id" => energy_mtr_type.id,
          "name" => "Energy Meter",
          "type" => "SensorType",
          "metadata_name" => "Current",
          "date_from" => Timex.shift(Timex.now(), months: -1),
          "date_to" => Timex.now(),
          "pos" => 1
        },
        %{
          "id" => apartment_type.id,
          "name" => "Apartment",
          "type" => "AssetType",
          "metadata_name" => "name",
          "pos" => 2
        }
      ]

      {:ok, _} =
        Topology.gen_sub_topology(
          fact_table.id,
          org_id,
          project,
          "fact table 1.1",
          fact_table,
          user_list,
          %{}
        )
    end
  end
end
