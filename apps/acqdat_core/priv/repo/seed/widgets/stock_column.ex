defmodule AcqdatCore.Seed.Widgets.StockColumn do
  @moduledoc """
  Holds seeds for Stock Column widgets.
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
        caption: [text: %{}, align: %{}],
        subtitle: [text: %{}, align: %{}, style: [color: %{value: "#74788d"}, fontSize: %{value: "14px"}]],
        yAxis: [title: [text: %{}]],
        rangeSelector: [selected: %{value: 1}],
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
            multiple: %{data_type: :boolean, value: %{data: false}, properties: %{}}
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
        title: %{text: "AAPL Stock Price"},
        rangeSelector: %{selected: 1},
        legend: %{enabled: true}
      },
      data_settings_values: %{
        series: [
          %{
            name: "AAPL",
            data: [
              %{x: 1533735000000, y: 207.25},
              %{x: 1533821400000, y: 208.88},
              %{x: 1533907800000, y: 207.53},
              %{x: 1534167000000, y: 208.87},
              %{x: 1534253400000, y: 209.75},
              %{x: 1534339800000, y: 210.24},
              %{x: 1534426200000, y: 213.32}
            ]
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

  def set_widget_data(_, widget_settings, data, widget_type) do
    %WidgetSchema{
      label: "Stock Column",
      properties: %{},
      uuid: UUID.uuid1(:hex),
      image_url: "https://www.highcharts.com/demo/images/samples/stock/demo/column/thumbnail.png",
      category: ["stock_chart", "column"],
      policies: %{},
      widget_type_id: widget_type.id,
      visual_settings: WidgetHelpers.do_settings(widget_settings, :visual, %HighCharts{}),
      data_settings: WidgetHelpers.do_settings(widget_settings, :data, %HighCharts{}),
      default_values: data
    }
  end

end
