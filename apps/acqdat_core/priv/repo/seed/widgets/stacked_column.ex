defmodule AcqdatCore.Seed.Widgets.StackedColumn do
  @moduledoc """
  Holds seeds for Stacked Column widgets.
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
        title: [text: %{}, align: %{}, style: [color: %{value: "#495057"}, fontSize: %{value: "15px"}]],
        subtitle: [text: %{}, align: %{}, style: [color: %{value: "#74788d"}, fontSize: %{value: "14px"}]],
        yAxis: [title: [text: %{}]],
        plotOptions: [column: [stacking: %{value: "normal"}, dataLabels: [enabled: %{value: true}]]],
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
        title: %{text: "Stacked column chart"},
        yAxis: %{
          title: %{
            text: "Total fruit consumption"
          }
        },
        plotOptions: %{
          column: %{
            stacking: "normal",
            dataLabels: %{
              enabled: true
            }
          }
        }
      },
      data_settings_values: %{
       series: [%{
          name: 'John',
          data: [["Apples", 5], ["Oranges",3], ["Pears", 4], ["Grapes", 7], ["Bananas",2]]
        }, %{
            name: 'Jane',
            data: [["Apples", 2], ["Oranges",2], ["Pears",3], ["Grapes",2], ["Bananas",1]]
        }, %{
            name: 'Joe',
            data: [["Apples", 3], ["Oranges",4], ["Pears",4], ["Grapes",2], ["Bananas",5]]
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

  def set_widget_data(_, widget_settings, data, widget_type) do
    %WidgetSchema{
      label: "Stacked Column",
      properties: %{},
      uuid: UUID.uuid1(:hex),
      classification: "standard",
      image_url: "https://assets.highcharts.com/images/demo-thumbnails/highcharts/column-stacked-default.png",
      category: ["chart", "column"],
      policies: %{},
      widget_type_id: widget_type.id,
      visual_settings: WidgetHelpers.do_settings(widget_settings, :visual, %HighCharts{}),
      data_settings: WidgetHelpers.do_settings(widget_settings, :data, %HighCharts{}),
      default_values: data
    }
  end

end
