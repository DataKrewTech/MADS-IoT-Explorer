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

    test "returns sensor data with timestamp, if user's input contains only one sensor_type(EnergyMtr) with metadata",
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
          "metadata_name" => "Current",
          "date_from" =>
            "#{Timex.shift(Timex.now(), months: -1) |> DateTime.to_unix(:millisecond)}",
          "date_to" => "#{Timex.now() |> DateTime.to_unix(:millisecond)}",
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

      query = "SELECT * FROM fact_table_#{fact_table.id}"

      data = Ecto.Adapters.SQL.query!(Repo, query, [])

      assert data.num_rows != 0
    end

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
  end
end
