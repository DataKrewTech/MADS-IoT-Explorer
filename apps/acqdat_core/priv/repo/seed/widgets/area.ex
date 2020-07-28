defmodule AcqdatCore.Seed.Widgets.Area do
  @moduledoc """
  Holds seeds for Area widgets.
  """
  alias AcqdatCore.Repo
  alias AcqdatCore.Seed.Helpers.WidgetHelpers
  alias AcqdatCore.Widgets.Schema.Widget, as: WidgetSchema

  @highchart_key_widget_settings %{
    area: %{
      visual: %{
        chart: [type: %{value: "area"}, backgroundColor: %{}, plotBackgroundColor: %{}],
        title: [text: %{}, align: %{}],
        caption: [text: %{}, align: %{}],
        subtitle: [text: %{}, align: %{}],
        yAxis: [title: [text: %{}]],
      },
      data: %{
        series: %{
          data_type: :list,
          value: %{},
          properties: %{
            name: %{data_type: :string, value: %{}, properties: %{}},
            color: %{data_type: :string, value: %{}, properties: %{}},
          }
        },
        axes: %{
          data_type: :object,
          value: %{},
          properties: %{
            x: %{data_type: :list, value: %{},
              properties: %{multiple: %{data_type: :boolean, value: %{data: false}, properties: %{}}}
            },
            y: %{data_type: :list, value: %{},
              properties: %{multiple: %{data_type: :boolean, value: %{data: true}, properties: %{}}}
            }
          }
        }
      }
    }
  }

  @high_chart_value_settings %{
    area: %{
      visual_setting_values: %{
        title: %{text: "US and USSR nuclear stockpiles"},
        caption: %{
           text: "Image description: An area chart compares the nuclear stockpiles of the USA and the USSR/Russia between 1945 and 2017. The number of nuclear weapons is plotted on the Y-axis and the years on the X-axis. The chart is interactive, and the year-on-year stockpile levels can be traced for each country. The US has a stockpile of 6 nuclear weapons at the dawn of the nuclear age in 1945. This number has gradually increased to 369 by 1950 when the USSR enters the arms race with 6 weapons. At this point, the US starts to rapidly build its stockpile culminating in 32,040 warheads by 1966 compared to the USSR’s 7,089. From this peak in 1966, the US stockpile gradually decreases as the USSR’s stockpile expands. By 1978 the USSR has closed the nuclear gap at 25,393. The USSR stockpile continues to grow until it reaches a peak of 45,000 in 1986 compared to the US arsenal of 24,401. From 1986, the nuclear stockpiles of both countries start to fall. By 2000, the numbers have fallen to 10,577 and 21,000 for the US and Russia, respectively. The decreases continue until 2017 at which point the US holds 4,018 weapons compared to Russia’s 4,500."
        },
        subtitle: %{
          text: "Source: https://thebulletin.org/2006/july/global-nuclear-stockpiles-1945-2006"
        },
        yAxis: %{
          title: %{
            text: "Nuclear weapon states"
          }
        }
      },
      data_settings_values: %{
        series: [
          %{
          name: "USA",
          data: [
              nil, nil, nil, nil, nil, 6, 11, 32, 110, 235,
              369, 640, 1005, 1436, 2063, 3057, 4618, 6444, 9822, 15468,
              20434, 24126, 27387, 29459, 31056, 31982, 32040, 31233, 29224, 27342,
              26662, 26956, 27912, 28999, 28965, 27826, 25579, 25722, 24826, 24605,
              24304, 23464, 23708, 24099, 24357, 24237, 24401, 24344, 23586, 22380,
              21004, 17287, 14747, 13076, 12555, 12144, 11009, 10950, 10871, 10824,
              10577, 10527, 10475, 10421, 10358, 10295, 10104, 9914, 9620, 9326,
              5113, 5113, 4954, 4804, 4761, 4717, 4368, 4018
          ]
      },
      %{
          name: "USSR/Russia",
          data: [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
              5, 25, 50, 120, 150, 200, 426, 660, 869, 1060,
              1605, 2471, 3322, 4238, 5221, 6129, 7089, 8339, 9399, 10538,
              11643, 13092, 14478, 15915, 17385, 19055, 21205, 23044, 25393, 27935,
              30062, 32049, 33952, 35804, 37431, 39197, 45000, 43000, 41000, 39000,
              37000, 35000, 33000, 31000, 29000, 27000, 25000, 24000, 23000, 22000,
              21000, 20000, 19000, 18000, 18000, 17000, 16000, 15537, 14162, 12787,
              12600, 11400, 5500, 4512, 4502, 4502, 4500, 4500
          ]
      }
    ]
     }
    }
  }

  def seed() do
    widget_type = WidgetHelpers.return_widget_type()
    seed_widgets(widget_type)
  end

  def seed_widgets(widget_type) do
    @highchart_key_widget_settings
    |> Enum.map(fn {key, widget_settings} ->
      set_widget_data(key, widget_settings, @high_chart_value_settings[key],
        widget_type)
    end)
    |> Enum.each(fn data ->
      Repo.insert!(data)
    end)
  end

  def set_widget_data(key, widget_settings, data, widget_type) do
    %WidgetSchema{
      label: to_string(key),
      properties: %{},
      uuid: UUID.uuid1(:hex),
      image_url: "https://assets.highcharts.com/images/demo-thumbnails/highcharts/area-basic-default.png",
      category: ["chart", "area"],
      policies: %{},
      widget_type_id: widget_type.id,
      visual_settings: WidgetHelpers.do_settings(widget_settings, :visual),
      data_settings: WidgetHelpers.do_settings(widget_settings, :data),
      default_values: data
    }
  end
end
