defmodule AcqdatCore.Seed.Widgets.PivotTable do
  @moduledoc """
  Holds seeds for PivotTable Widget.
  """

  alias AcqdatCore.Repo
  alias AcqdatCore.Seed.Helpers.WidgetHelpers
  alias AcqdatCore.Widgets.Schema.Widget, as: WidgetSchema
  alias AcqdatCore.Widgets.Schema.Vendors.HighCharts

  @custom_card_key_widget_settings %{
    pivot_table: %{
      visual: %{
      },
      data: %{
        series: %{
          data_type: :object,
          value: %{},
          properties: %{
            name: %{data_type: :string, value: %{}, properties: %{}},
            multiple: %{data_type: :boolean, value: %{data: false}, properties: %{}}
          }
        },
        axes: %{
          data_type: :object,
          value: %{},
          properties: %{
            multiple: %{data_type: :boolean, value: %{data: true}, properties: %{}},
            rows: %{data_type: :list, value: %{}, properties: %{}},
            columns: %{data_type: :list, value: %{}, properties: %{}},
            values: %{data_type: :list, value: %{}, properties: %{}}
          }
        }
      }
    }
  }

  @custom_card_value_settings %{
     pivot_table: %{
      visual_setting_values: %{
      },
      data_settings_values: %{
        series: [
          %{
            name: "Installation",
            data: [["Year", "Category", "Occupancy"],["2010", "A", 15], ["2011", "A", 17], ["2012", "A", 21],
            ["2010", "B", 25], ["2011", "B", 33], ["2012", "B", 34],
          ["2010", "C", 51], ["2011", "C", 50], ["2012", "C", 47]]
          }
        ]
     }
    }
  }

  def seed() do
    #widget_type = WidgetHelpers.find_or_create_widget_type("PivotTable")
    widget_type = WidgetHelpers.find_or_create_widget_type("HighCharts")
    seed_widgets(widget_type)
  end

  def seed_widgets(widget_type) do
    @custom_card_key_widget_settings
    |> Enum.map(fn {key, widget_settings} ->
      set_widget_data(key, widget_settings, @custom_card_value_settings[key],
        widget_type)
    end)
    |> Enum.each(fn data ->
      Repo.insert!(data)
    end)
  end

  def set_widget_data(_, widget_settings, data, widget_type) do
    %WidgetSchema{
      label: "PivotTable",
      properties: %{},
      uuid: UUID.uuid1(:hex),
      classification: "standard",
      image_url: "https://i.imgur.com/KfHsf0S.png",
      category: ["pivot_table"],
      policies: %{},
      widget_type_id: widget_type.id,
      visual_settings: WidgetHelpers.do_settings(widget_settings, :visual, %HighCharts{}),
      data_settings: WidgetHelpers.do_settings(widget_settings, :data, %HighCharts{}),
      default_values: data
    }
  end
end
