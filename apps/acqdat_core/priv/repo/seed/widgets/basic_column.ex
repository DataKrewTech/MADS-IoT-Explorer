defmodule AcqdatCore.Seed.Widgets.BasicColumn do
  @moduledoc """
  Holds seeds for Basic Column widgets.
  """
  use AcqdatCore.Seed.Helpers.HighchartsUpdateHelpers
  alias AcqdatCore.Repo
  alias AcqdatCore.Seed.Helpers.WidgetHelpers
  alias AcqdatCore.Widgets.Schema.Widget, as: WidgetSchema
  alias AcqdatCore.Widgets.Schema.Vendors.HighCharts

  @highchart_key_widget_settings %{
    column: %{
      visual: %{
        chart: [type: %{value: "column"}, backgroundColor: %{}, plotBackgroundColor: %{}],
        title: [text: %{}, align: %{}, style: [color: %{value: "#333333"}, fontSize: %{value: "18px"}]],
        subtitle: [text: %{}, align: %{}, style: [color: %{value: "#333333"}, fontSize: %{value: "18px"}]],
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
    column: %{
      visual_setting_values: %{
        title: %{text: "Monthly Average Rainfall"},
        subtitle: %{
          text: "Source: WorldClimate.com"
        },
        yAxis: %{
          title: %{
            text: "Rainfall (mm)"
          }
        }
      },
      data_settings_values: %{
        series: [
          %{
            name: "Tokyo",
            data: [["Jan", 49.9], ["Feb", 71.5], ["March", 106.4], ["April", 129.2], ["May", 144.0], ["June", 176.0], ["July", 135.6], ["Aug", 148.5], ["Sep", 216.4], ["Oct", 194.1], ["Nov", 95.6], ["Dec", 54.4]]
          }, %{
            name: "New York",
            data: [["Jan", 70], ["Feb", 50.5], ["March", 126.4], ["April", 29.2], ["May", 190.0], ["June", 16.0], ["July", 15.6], ["Aug", 198.5], ["Sep", 116.4], ["Oct", 294.1], ["Nov", 195.6], ["Dec", 154.4]]
          }, %{
            name: "London",
            data: [["Jan", 149.9], ["Feb", 171.5], ["March", 26.4], ["April", 229.2], ["May", 44.0], ["June", 76.0], ["July", 35.6], ["Aug", 48.5], ["Sep", 26.4], ["Oct", 94.1], ["Nov", 152.6], ["Dec", 140.4]]
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
      label: "Basic Column",
      properties: %{},
      uuid: UUID.uuid1(:hex),
      classification: "standard",
      image_url: "https://assets.highcharts.com/images/demo-thumbnails/highcharts/column-basic-default.png",
      category: ["chart", "column"],
      policies: %{},
      widget_type_id: widget_type.id,
      visual_settings: WidgetHelpers.do_settings(widget_settings, :visual, %HighCharts{}),
      data_settings: WidgetHelpers.do_settings(widget_settings, :data, %HighCharts{}),
      default_values: data
    }
  end

end
