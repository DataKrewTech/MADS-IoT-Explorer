defmodule AcqdatCore.Seed.Widgets.LineTimeseries do
  @moduledoc """
  Holds seeds for Line widgets.
  """
  use AcqdatCore.Seed.Helpers.HighchartsUpdateHelpers
  alias AcqdatCore.Repo
  alias AcqdatCore.Seed.Helpers.WidgetHelpers
  alias AcqdatCore.Widgets.Schema.Widget, as: WidgetSchema
  alias AcqdatCore.Widgets.Schema.Vendors.HighCharts

  @highchart_key_widget_settings %{
    line: %{
      visual: %{
        chart: [type: %{value: "line"}, backgroundColor: %{}, plotBackgroundColor: %{}],
        title: [text: %{}, align: %{}],
        caption: [text: %{}, align: %{}],
        subtitle: [text: %{}, align: %{}],
        yAxis: [title: [text: %{}]],
        xAxis: [type: %{value: "datetime"}, title: [text: %{value: "Date"}]],
        credits: [enabled: %{value: false}],
        legend: [enabled: %{value: true}]
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
    line: %{
      visual_setting_values: %{
        title: %{text: "Solar Employment growth by year"},
        caption: %{
           text: "A brief description of the data being stored by
                the chart here."
        },
        subtitle: %{
          text: "Source: thesolarfoundation.com"
        },
        yAxis: %{
          title: %{
            text: "Number of Employees"
          }
        }
      },
      data_settings_values: %{
        series: [
          %{
            name: "Installation",
            data: [43934, 52503, 57177, 69658, 97031, 119931, 137133, 154175]
          }, %{
            name: "Manufacturing",
            data: [24916, 24064, 29742, 29851, 32490, 30282, 38121, 40434]
          }, %{
            name: "Sales & Distribution",
            data: [11744, 17722, 16005, 19771, 20185, 24377, 32147, 39387]
          }, %{
            name: "Project Development",
            data: ["null", "null", 7988, 12169, 15112, 22452, 34400, 34227]
          }, %{
            name: "Other",
            data: [12908, 5948, 8105, 11248, 8989, 11816, 18274, 18111]
          }
        ]
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
      WidgetHelpers.create("widgets", data)
    end)
  end

  def set_widget_data(key, widget_settings, data, widget_type) do
    %WidgetSchema{
      label: "Line Timeseries",
      properties: %{},
      uuid: UUID.uuid1(:hex),
      image_url: "https://assets.highcharts.com/images/demo-thumbnails/highcharts/line-time-series-default.png",
      category: ["chart", "line"],
      policies: %{},
      widget_type_id: widget_type.id,
      visual_settings: WidgetHelpers.do_settings(widget_settings, :visual, %HighCharts{}),
      data_settings: WidgetHelpers.do_settings(widget_settings, :data, %HighCharts{}),
      default_values: data
    }
  end

end
