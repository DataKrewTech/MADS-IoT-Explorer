defmodule AcqdatCore.Seed.Widgets.SolidGauge do
  @moduledoc """
  Holds seeds for gauge-series widgets.
  """
  alias AcqdatCore.Repo
  alias AcqdatCore.Seed.Helpers.WidgetHelpers
  alias AcqdatCore.Widgets.Schema.Widget, as: WidgetSchema
  alias AcqdatCore.Widgets.Schema.Vendors.HighCharts

  @highchart_key_widget_settings %{
    solidgauge: %{
      visual: %{
        chart: [type: %{value: "solidgauge"}, backgroundColor: %{}, plotBackgroundColor: %{}],
        title: [text: %{}, align: %{}],
        yAxis: [title: [text: %{},  y: %{data_type: :integer, value: -70, properties: %{}}], min: %{data_type: :integer, value: 0, properties: %{}},
                max: %{data_type: :integer, value: 200, properties: %{}}],
        credits: [enabled: %{value: false}],
        pane: [startAngle: %{data_type: :integer, value: -90, properties: %{}},
               endAngle: %{data_type: :integer, value: 90, properties: %{}},
               size: %{data_type: :string, value: "140%", properties: %{}},
               center: %{data_type: :list, value: ["50%", "85%"], properties: %{}},
               background: [
                backgroundColor: %{data_type: :color, value: "#EEE", properties: %{}},
                innerRadius: %{data_type: :string, value: "60%", properties: %{}},
                outerRadius: %{data_type: :string, value: "100%", properties: %{}},
                shape: %{data_type: :string, value: "arc", properties: %{}}
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
    solidgauge: %{
      visual_setting_values: %{
        yAxis: %{
          title: %{
            text: "RPM",
            y: -70,
          },
          min: 0,
          max: 5
        },
        pane: %{
        center: ["50%", "85%"],
        size: "140%",
        startAngle: -90,
        endAngle: 90,
        background: [%{
            backgroundColor: "#EEE",
            outerRadius: "100%",
            innerRadius: "60%",
            shape: "arc"
          }]
        }
      },
      data_settings_values: %{
        series: [
          %{
            name: "RPM",
            data: [%{y: 2}]
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
      image_url: "https://assets.highcharts.com/images/demo-thumbnails/highcharts/gauge-solid-default.png",
      category: ["chart", "solid gauge"],
      policies: %{},
      widget_type_id: widget_type.id,
      visual_settings: WidgetHelpers.do_settings(widget_settings, :visual, %HighCharts{}),
      data_settings: WidgetHelpers.do_settings(widget_settings, :data, %HighCharts{}),
      default_values: data
    }
  end
end
