defmodule AcqdatCore.Schema.MetricsTest do
  use ExUnit.Case, async: true
  alias AcqdatCore.Schema.Metrics
  alias AcqdatCore.Repo

  describe "changeset" do
    test "metrics - returns a valid changeset" do
      params = dummy_data()
      changeset = Metrics.changeset(%Metrics{}, %{metrics: params})
      %{valid?: validity} = changeset
      assert validity
      # Repo.insert(changeset)
    end
  end

  defp dummy_data() do
    %{
    dashboards: %{
      dashboards: %{
        count: 2,
        metadata: %{
          data: [
            {1, "Test Dashboard"},
            {2, "VSUN"},
          ]
        }
      },
      panels: %{
        count: 2,
        metadata: %{
          data: [
            {1, "Battery"},
            {2, "Home"}
          ]
        }
      },
      widgets: %{
        count: 4,
        metadata: %{
          data: [
            {"e8986efa6f7211eba1760242ac1b000b", "Labelqwy8zoahffy8b5hma1fy"},
            {"57fd2bd26f7311eb950b0242ac1b000b", "Labelfx7yeyca966re8o32y25"},
            {"9d5101266f7411eb811a0242ac1b000b", "Label221qqg05qe62qedzvdrj"},
            {"06ec901a702311eb8e0b0242ac1b000b", "Labelaphdwdzoz0rc597ezc8r"},
            {"6e05f20a6c3611ebae140242ac1b000b", "Labelwewsxscf59m4xhgud4da"},
          ]
        }
      }
    },
    data_insights: %{
      fact_tables: %{count: 1, metadata: %{data: [{266, "AT1"}]}},
      visualisations: %{count: 2, metadata: %{data: [{63, "1"}, {64, "2"}]}}
    },
    entities: %{
      active_parameters: %{count: 0, metadata: []},
      asset_types: %{count: 1, metadata: %{data: [{44, "PowerCube"}]}},
      assets: %{
        count: 2,
        metadata: %{data: [{"VSUN 5-30 V1", 195}, {"Power Cube 10-100", 214}]}
      },
      gateways: %{
        count: 2,
        metadata: %{
          data: [{"Gateway Cleantech 10-100", 47}, {"VSUN V1 5-30 Gateway", 28}]
        }
      },
      projects: %{count: 1, metadata: %{data: [{70, "JTC Cleantech 1"}]}},
      sensor_types: %{
        count: 2,
        metadata: %{data: [{54, "PowerCubePramsV1"}, {51, "PowerCubeParams"}]}
      },
      sensors: %{
        count: 4,
        metadata: %{
          data: [
            {"Power Cube Additional Params", 332},
            {"VSUN Sensor V2", 339},
            {"VSUN Sensor V1", 320},
            {"Power Cube Main Params", 331}
          ]
        }
      }
    }
  }
  end
end
