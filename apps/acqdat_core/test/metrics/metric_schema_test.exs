defmodule AcqdatCore.Schema.MetricsTest do
  use ExUnit.Case, async: true
  alias AcqdatCore.Schema.Metrics
  alias AcqdatCore.Repo
  alias AcqdatCore.Metrics.{OrgMetrics, Reports}

  import AcqdatCore.Support.Factory
  alias AcqdatCore.Schema.EntityManagement.{Asset}

  describe "changeset" do
    test "returns a valid changeset" do
      params = dummy_data()

      changeset =
        Metrics.changeset(%Metrics{}, %{
          inserted_time: DateTime.truncate(DateTime.utc_now(), :second),
          org_id: 123,
          metrics: params
        })

      %{valid?: validity} = changeset
      assert validity
    end

    test "successfully updates database" do
      Ecto.Adapters.SQL.Sandbox.checkout(AcqdatCore.Repo)
      params = dummy_data()
      time = DateTime.truncate(DateTime.utc_now(), :second)

      changeset =
        Metrics.changeset(%Metrics{}, %{inserted_time: time, org_id: 123, metrics: params})

      Repo.insert!(changeset)
      data = Repo.all(Metrics)
      {:ok, test_meta} = Map.fetch(hd(data).metrics.dashboards.dashboards, "metadata")
      {:ok, test_data} = Map.fetch(test_meta, "data")
      {:ok, test_value} = Map.fetch(hd(test_data), "value")
      assert test_value == "Test Dashboard"
    end
  end

  describe "measure_and_dump" do
    test "successfully updates database with organisation info" do
      Ecto.Adapters.SQL.Sandbox.checkout(AcqdatCore.Repo)
      initial_size = Enum.count(Repo.all(Metrics))
      insert(:asset)
      insert(:asset)
      insert(:asset)
      OrgMetrics.measure_and_dump()
      final_size = Enum.count(Repo.all(Metrics))
      refute initial_size == final_size
    end
  end

  describe "daily_report" do
    test "rejects bad org_id" do
      Ecto.Adapters.SQL.Sandbox.checkout(AcqdatCore.Repo)
      {:error, result} = Reports.daily_report(-43)
      assert result == "Organisation does not exist"
    end

    test "returns existing same day record if available" do
      Ecto.Adapters.SQL.Sandbox.checkout(AcqdatCore.Repo)
      asset = insert(:asset)
      time = DateTime.truncate(DateTime.utc_now(), :second)
      OrgMetrics.measure_and_dump()
      :timer.sleep(2000)
      {:ok, result} = Reports.daily_report(asset.org_id)
      assert DateTime.diff(result.inserted_time, time) <= 1
    end

    test "generates valid record if not already available" do
      Ecto.Adapters.SQL.Sandbox.checkout(AcqdatCore.Repo)
      asset = insert(:asset)
      {:ok, result} = Reports.daily_report(asset.org_id)
      assert result.org_id == asset.org_id
    end
  end

  defp dummy_data() do
    %{
      dashboards: %{
        dashboards: %{
          count: 2,
          metadata: %{
            data: [
              %{id: 1, value: "Test Dashboard"},
              %{id: 2, value: "VSUN"}
            ]
          }
        },
        panels: %{
          count: 2,
          metadata: %{
            data: [
              %{id: 1, value: "Battery"},
              %{id: 2, value: "Home"}
            ]
          }
        },
        widgets: %{
          count: 4,
          metadata: %{
            data: [
              %{id: "e8986efa6f7211eba1760242ac1b000b", value: "Labelqwy8zoahffy8b5hma1fy"},
              %{id: "57fd2bd26f7311eb950b0242ac1b000b", value: "Labelfx7yeyca966re8o32y25"},
              %{id: "9d5101266f7411eb811a0242ac1b000b", value: "Label221qqg05qe62qedzvdrj"},
              %{id: "06ec901a702311eb8e0b0242ac1b000b", value: "Labelaphdwdzoz0rc597ezc8r"},
              %{id: "6e05f20a6c3611ebae140242ac1b000b", value: "Labelwewsxscf59m4xhgud4da"}
            ]
          }
        }
      },
      data_insights: %{
        fact_tables: %{count: 1, metadata: %{data: [%{id: 266, value: "AT1"}]}},
        visualisations: %{
          count: 2,
          metadata: %{data: [%{id: 63, value: "1"}, %{id: 64, value: "2"}]}
        }
      },
      entities: %{
        active_parameters: %{count: 0, metadata: []},
        asset_types: %{count: 1, metadata: %{data: [%{id: 44, value: "PowerCube"}]}},
        assets: %{
          count: 2,
          metadata: %{
            data: [%{id: "VSUN 5-30 V1", value: 195}, %{id: "Power Cube 10-100", value: 214}]
          }
        },
        gateways: %{
          count: 2,
          metadata: %{
            data: [
              %{id: "Gateway Cleantech 10-100", value: 47},
              %{id: "VSUN V1 5-30 Gateway", value: 28}
            ]
          }
        },
        projects: %{count: 1, metadata: %{data: [%{id: 70, value: "JTC Cleantech 1"}]}},
        sensor_types: %{
          count: 2,
          metadata: %{
            data: [%{id: 54, value: "PowerCubePramsV1"}, %{id: 51, value: "PowerCubeParams"}]
          }
        },
        sensors: %{
          count: 4,
          metadata: %{
            data: [
              %{id: "Power Cube Additional Params", value: 332},
              %{id: "VSUN Sensor V2", value: 339},
              %{id: "VSUN Sensor V1", value: 320},
              %{id: "Power Cube Main Params", value: 331}
            ]
          }
        }
      }
    }
  end
end
