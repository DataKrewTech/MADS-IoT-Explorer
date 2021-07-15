defmodule AcqdatCore.Seed.Widgets.TableTimeseries do
  @moduledoc """
  Holds seeds for TableTimeseries widgets.
  """
  use AcqdatCore.Seed.Helpers.CustomCardUpdateHelpers
  alias AcqdatCore.Repo
  alias AcqdatCore.Seed.Helpers.WidgetHelpers
  alias AcqdatCore.Widgets.Schema.Widget, as: WidgetSchema
  alias AcqdatCore.Widgets.Schema.Vendors.CustomCards

  @custom_card_key_widget_settings %{
    card: %{
      visual: %{
        card: [type: %{value: "table timeseries"}, backgroundColor: %{}, fontColor: %{}],
        title: [text: %{}, align: %{}, fontSize: %{value: "15px"}, fontColor: %{value: "#495057"}]
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
    card: %{
      visual_setting_values: %{
        title: %{text: "temp"}
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
    widget_type = WidgetHelpers.find_or_create_widget_type("CustomCards")
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

  def set_widget_data(_key, widget_settings, data, widget_type) do
    %WidgetSchema{
      label: "Table Timeseries",
      properties: %{},
      uuid: UUID.uuid1(:hex),
      image_url: "https://i.imgur.com/ix0Agv4.png",
      category: ["card", "table_timeseries"],
      policies: %{},
      widget_type_id: widget_type.id,
      visual_settings: WidgetHelpers.do_settings(widget_settings, :visual, %CustomCards{}),
      data_settings: WidgetHelpers.do_settings(widget_settings, :data, %CustomCards{}),
      default_values: data
    }
  end
end
