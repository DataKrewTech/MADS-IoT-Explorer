defmodule AcqdatCore.Seed.Widgets.HeatMap do
  @moduledoc """
  Holds seeds for HeatMap Widget.
  """
  use AcqdatCore.Seed.Helpers.AnyChartUpdateHelpers
  alias AcqdatCore.Repo
  alias AcqdatCore.Seed.Helpers.WidgetHelpers
  alias AcqdatCore.Widgets.Schema.Widget, as: WidgetSchema
  alias AcqdatCore.Widgets.Schema.Vendors.AnyChart

  @any_chart_key_widget_settings %{
    heat_map: %{
      visual: %{
        anychart: [type: %{value: "heat_map"}],
        title: [text: %{}]
      },
      data: %{
        series: %{
          data_type: :object,
          value: %{},
          properties: %{
            name: %{data_type: :string, value: %{}, properties: %{}},
            multiple: %{data_type: :boolean, value: %{data: true}, properties: %{}}
          }
        },
        axes: %{
          data_type: :object,
          value: %{},
          properties: %{
            multiple: %{data_type: :boolean, value: %{data: true}, properties: %{}},
            x: %{data_type: :list, value: %{}, properties: %{}},
            y: %{data_type: :list, value: %{}, properties: %{}},
            value: %{data_type: :list, value: %{}, properties: %{}}
          }
        }
      }
    }
  }

  @any_chart_value_settings %{
    heat_map: %{
      visual_setting_values: %{
        title: %{text: "Basic Sample"}
      },
      data_settings_values: %{
        series: [
          %{
            data: [["2010", "A", 15], ["2011", "A", 17], ["2012", "A", 21],
            ["2010", "B", 25], ["2011", "B", 33], ["2012", "B", 34],
          ["2010", "C", 51], ["2011", "C", 50], ["2012", "C", 47]]
          }
        ]
     }
    }
  }

  def seed() do
    widget_type = WidgetHelpers.find_or_create_widget_type("AnyChart")
    seed_widgets(widget_type)
  end

  def seed_widgets(widget_type) do
    @any_chart_key_widget_settings
    |> Enum.map(fn {key, widget_settings} ->
      set_widget_data(key, widget_settings, @any_chart_value_settings[key],
        widget_type)
    end)
    |> Enum.each(fn data ->
      Repo.insert!(data)
    end)
  end

  def set_widget_data(_, widget_settings, data, widget_type) do
    %WidgetSchema{
      label: "HeatMap",
      properties: %{},
      uuid: UUID.uuid1(:hex),
      classification: "standard",
      image_url: "https://i.imgur.com/ix0Agv4.png",
      category: ["anychart", "heat_map"],
      policies: %{},
      widget_type_id: widget_type.id,
      visual_settings: WidgetHelpers.do_settings(widget_settings, :visual, %AnyChart{}),
      data_settings: WidgetHelpers.do_settings(widget_settings, :data, %AnyChart{}),
      default_values: data
    }
  end
end
