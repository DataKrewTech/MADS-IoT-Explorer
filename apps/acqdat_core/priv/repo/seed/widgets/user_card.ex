defmodule AcqdatCore.Seed.Widgets.UserCard do
  @moduledoc """
  Holds seeds for UserCard widgets.
  """
  use AcqdatCore.Seed.Helpers.CustomCardUpdateHelpers
  alias AcqdatCore.Repo
  alias AcqdatCore.Seed.Helpers.WidgetHelpers
  alias AcqdatCore.Widgets.Schema.Widget, as: WidgetSchema
  alias AcqdatCore.Widgets.Schema.Vendors.CustomCards

  @custom_card_key_widget_settings %{
    card: %{
      visual: %{
        card: [type: %{value: "user card"}, backgroundColor: %{}, fontColor: %{}],
        image: [url: %{}, align: %{value: ["left", "right", "center", "top", "bottom"]}],
        title: [text: %{}, align: %{value: ["left", "right", "center", "top", "bottom"]}, fontSize: %{value: "12px"}, fontColor: %{value: "#495057"}],
        subtitle: [text: %{}, fontSize: %{value: "12px"}, fontColor: %{value: "#74788d"}, align: %{value: ["left", "right", "center", "top", "bottom"]}]
      }
    }
  }

  @custom_card_value_settings %{
    card: %{
      visual_setting_values: %{
        title: %{text: "temp"}
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
      label: "User Card",
      properties: %{},
      uuid: UUID.uuid1(:hex),
      classification: "latest",
      image_url: "https://i.imgur.com/ix0Agv4.png",
      category: ["card", "user_card"],
      policies: %{},
      widget_type_id: widget_type.id,
      visual_settings: WidgetHelpers.do_settings(widget_settings, :visual, %CustomCards{}),
      default_values: data
    }
  end
end
