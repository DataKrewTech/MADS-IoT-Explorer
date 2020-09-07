defmodule AcqdatCore.Seed.Widgets.GaugeSeries do
  @moduledoc """
  Holds seeds for gauge-series widgets.
  """
  alias AcqdatCore.Repo
  alias AcqdatCore.Seed.Helpers.WidgetHelpers
  alias AcqdatCore.Widgets.Schema.Widget, as: WidgetSchema
  alias AcqdatCore.Widgets.Schema.Vendors.HighCharts

  @highchart_key_widget_settings %{
    gauge: %{
      visual: %{
        chart: [type: %{value: "gauge"}, backgroundColor: %{}, plotBackgroundColor: %{}],
        title: [text: %{}, align: %{}],
        yAxis: [title: [text: %{}], min: %{data_type: :integer, value: 0, properties: %{}},
                max: %{data_type: :integer, value: 200, properties: %{}},
                tickPixelInterval: %{data_type: :integer, value: 30, properties: %{}},
                labels: [step: %{data_type: :integer, value: 2, properties: %{}},
                rotation: %{data_type: :string, value: "auto", properties: %{}}],
                plotBands: %{
                  data_type: :list,
                  value: [%{
                      color: "#55BF3B",
                      from: 0,
                      to: 120
                    }, %{
                      color: "#DDDF0D",
                      from: 120,
                      to: 160
                    }, %{
                      color: "#DF5353",
                      from: 160,
                      to: 200
                  }],
                  properties: %{
                    color: %{data_type: :color, value: "#55BF3B", properties: %{}},
                    from: %{data_type: :integer, value: 0, properties: %{}},
                    to: %{data_type: :integer, value: 120, properties: %{}}
                  }
                }
              ],
        credits: [enabled: %{value: false}],
        pane: [startAngle: %{data_type: :integer, value: -150, properties: %{}},
               endAngle: %{data_type: :integer, value: 150, properties: %{}},
               background: [
                backgroundColor: %{data_type: :color, value: "#DDD", properties: %{}},
                innerRadius: %{data_type: :string, value: "0", properties: %{}},
                outerRadius: %{data_type: :string, value: "109", properties: %{}},
                borderColor: %{data_type: :color, value: "#cccccc", properties: %{}}
              ]
             ]
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
            y: %{data_type: :list, value: %{}, properties: %{}}
          }
        }
      }
    }
  }

  @high_chart_value_settings %{
    gauge: %{
      visual_setting_values: %{
        title: %{text: "Speedometer"},
        yAxis: %{
          title: %{
            text: "km/h"
          },
          min: 0,
          max: 200,
          tickPixelInterval: 30,
          labels: %{
            step: 2,
            rotation: "auto"
          },
          plotBands: [%{
              color: "#55BF3B",
              from: 0,
              to: 120
            }, %{
              color: "#DDDF0D",
              from: 120,
              to: 160
            }, %{
              color: "#DF5353",
              from: 160,
              to: 200
          }]
        },
        pane: %{
        startAngle: -150,
        endAngle: 150,
        background: [%{
            backgroundColor: "#DDD",
            outerRadius: "105%",
            innerRadius: "103%"
          }]
        }
      },
      data_settings_values: %{
        series: [
          %{
            name: "Speed",
            data: [%{y: 80}]
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
    end)
  end

  def set_widget_data(key, widget_settings, data, widget_type) do
    %WidgetSchema{
      label: to_string(key),
      properties: %{},
      uuid: UUID.uuid1(:hex),
      classification: "latest",
      image_url: "https://assets.highcharts.com/images/demo-thumbnails/highcharts/gauge-speedometer-default.png",
      category: ["chart", "gauge"],
      policies: %{},
      widget_type_id: widget_type.id,
      visual_settings: WidgetHelpers.do_settings(widget_settings, :visual, %HighCharts{}),
      data_settings: WidgetHelpers.do_settings(widget_settings, :data, %HighCharts{}),
      default_values: data
    }
  end
end
