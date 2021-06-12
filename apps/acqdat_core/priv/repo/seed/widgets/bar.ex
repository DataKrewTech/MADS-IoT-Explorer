defmodule AcqdatCore.Seed.Widgets.Bar do
  @moduledoc """
  Holds seeds for Bar widgets.
  """
  use AcqdatCore.Seed.Helpers.HighchartsUpdateHelpers
  alias AcqdatCore.Repo
  alias AcqdatCore.Seed.Helpers.WidgetHelpers
  alias AcqdatCore.Widgets.Schema.Widget, as: WidgetSchema
  alias AcqdatCore.Widgets.Schema.Vendors.HighCharts

  @highchart_key_widget_settings %{
    bar: %{
      visual: %{
        chart: [type: %{value: "bar"}, backgroundColor: %{}, plotBackgroundColor: %{}],
        title: [text: %{}, align: %{}, style: [color: %{value: "#495057"}, fontSize: %{value: "15px"}]],
        caption: [text: %{}, align: %{}],
        subtitle: [text: %{}, align: %{}, style: [color: %{value: "#74788d"}, fontSize: %{value: "14px"}]],
        yAxis: [title: [text: %{}]],
        credits: [enabled: %{value: false}],
      },
      data: %{
        series: %{
          data_type: :object,
          value: %{},
          properties: %{
            name: %{data_type: :string, value: %{}, properties: %{}},
            color: %{data_type: :color, value: %{data: "#000000"}, properties: %{}},
            multiple: %{data_type: :boolean, value: %{data: true}, properties: %{}}
          }
        },
        axes: %{
          data_type: :object,
          value: %{},
          properties: %{
            multiple: %{data_type: :boolean, value: %{data: true}, properties: %{}},
            x: %{data_type: :list, value: %{}, properties: %{}},
            y: %{data_type: :list, value: %{}, properties: %{}}
          }
        }
      }
    }
  }

  @high_chart_value_settings %{
    bar: %{
      visual_setting_values: %{
        title: %{text: "Historic World Population by Region"},
        caption: %{
           text: "Image description: An bar chart compares the nuclear stockpiles of the USA and the USSR/Russia between 1945 and 2017. The number of nuclear weapons is plotted on the Y-axis and the years on the X-axis. The chart is interactive, and the year-on-year stockpile levels can be traced for each country. The US has a stockpile of 6 nuclear weapons at the dawn of the nuclear age in 1945. This number has gradually increased to 369 by 1950 when the USSR enters the arms race with 6 weapons. At this point, the US starts to rapidly build its stockpile culminating in 32,040 warheads by 1966 compared to the USSR’s 7,089. From this peak in 1966, the US stockpile gradually decreases as the USSR’s stockpile expands. By 1978 the USSR has closed the nuclear gap at 25,393. The USSR stockpile continues to grow until it reaches a peak of 45,000 in 1986 compared to the US arsenal of 24,401. From 1986, the nuclear stockpiles of both countries start to fall. By 2000, the numbers have fallen to 10,577 and 21,000 for the US and Russia, respectively. The decreases continue until 2017 at which point the US holds 4,018 weapons compared to Russia’s 4,500."
        },
        subtitle: %{
          text: "Source: https://en.wikipedia.org/wiki/World_population"
        },
        yAxis: %{
          title: %{
            text: "Population (millions)"
          }
        }
      },
      data_settings_values: %{
        series: [
          %{
          name: "Year 1800",
          data: [["Africa", 107], ["America", 31], ["Asia", 635], ["Europe", 203], ["Oceania", 2]]
      },
      %{
          name: "Year 1900",
          data: [["Africa", 133], ["America", 156], ["Asia", 947], ["Europe", 408], ["Oceania", 6]]
      },
      %{
          name: "Year 2000",
          data: [["Africa", 814], ["America", 841], ["Asia", 3714], ["Europe", 727], ["Oceania", 31]]
      },
      %{
          name: "Year 2016",
          data: [["Africa", 1216], ["America", 1001], ["Asia", 4436], ["Europe", 738], ["Oceania", 40]]
      }]
     }
    }
  }

  def seed() do
    widget_type = WidgetHelpers.find_or_create_widget_type("HighCharts")
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
      classification: "standard",
      image_url: "https://assets.highcharts.com/images/demo-thumbnails/highcharts/bar-basic-default.png",
      category: ["chart", "bar"],
      policies: %{},
      widget_type_id: widget_type.id,
      visual_settings: WidgetHelpers.do_settings(widget_settings, :visual, %HighCharts{}),
      data_settings: WidgetHelpers.do_settings(widget_settings, :data, %HighCharts{}),
      default_values: data
    }
  end

end
