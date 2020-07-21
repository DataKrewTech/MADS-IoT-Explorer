defmodule AcqdatCore.Seed.Widgets.Pie do
  @moduledoc """
  Holds seeds for Pie widgets.
  """
  alias AcqdatCore.Repo
  alias AcqdatCore.Seed.Helpers.WidgetHelpers
  alias AcqdatCore.Widgets.Schema.Widget, as: WidgetSchema

  @highchart_key_widget_settings %{
    pie: %{
      visual: %{
        chart: [type: %{value: "pie"}, backgroundColor: %{}, plotBackgroundColor: %{}],
        title: [text: %{}, align: %{}],
        caption: [text: %{}, align: %{}],
        subtitle: [text: %{}, align: %{}],
        yAxis: [title: [text: %{}]],
      },
      data: %{
        series: %{
          data_type: :object,
          value: %{},
          properties: %{
            name: %{data_type: :string, value: %{}, properties: %{}},
            color: %{data_type: :color, value: %{}, properties: %{}},
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
    pie: %{
      visual_setting_values: %{
        title: %{text: "Browser market shares in January, 2018"},
        caption: %{
           text: "Market Share of different browsers"
        },
        subtitle: %{
        },
        yAxis: %{
          title: %{
          }
        }
      },
      data_settings_values: %{
        series: [%{
          name: "Brands",
          colorByPoint: true,
          data: [%{
              name: "Chrome",
              y: 61.41,
              sliced: true,
              selected: true
          }, %{
              name: "Internet Explorer",
              y: 11.84
          }, %{
              name: "Firefox",
              y: 10.85
          }, %{
              name: "Edge",
              y: 4.67
          }, %{
              name: "Safari",
              y: 4.18
          }, %{
              name: "Sogou Explorer",
              y: 1.64
          }, %{
              name: "Opera",
              y: 1.6
          }, %{
              name: "QQ",
              y: 1.2
          }, %{
              name: "Other",
              y: 2.61
          }]
      }]
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
      image_url: "https://assets.highcharts.com/images/demo-thumbnails/highcharts/pie-basic-default.png",
      category: ["chart", "pie"],
      policies: %{},
      widget_type_id: widget_type.id,
      visual_settings: WidgetHelpers.do_settings(widget_settings, :visual),
      data_settings: WidgetHelpers.do_settings(widget_settings, :data),
      default_values: data
    }
  end
end
