defmodule AcqdatCore.DashboardManagement.Schema.CommandWidget.LEDControl do
  @moduledoc """
  Adds schema and controls for LEDControl Widget.
  """
  use AcqdatCore.Schema
  @behaviour AcqdatCore.DashboardManagement.Schema.CommandWidget
  @widget_type "html"
  @widget_name "LED Control"

  defstruct [
    gateway: nil,
    data_settings: %{
      rgb_mode: %{
        html_tag: "select",
        source: %{"off" => 0, "spectrum cycling" => 1, "breathing" => 2, "solid" => 3},
        default: 3,
        value: nil
      },
      w_mode: %{
        html_type: "select",
        source: %{"off" => 0, "breathing" => 1, "solid" => 2},
        default: 2,
        value: nil
      },
      rgb_color: %{html_tag: "input", html_type: "color", value: nil},
      intensity: %{html_tag: "input", html_type: "range", min: 0, max: 255, value: nil},
      warm_white: %{html_tag: "input", html_type: "range", min: 0, max: 30_000, value: nil},
      cold_white: %{html_tag: "input", html_type: "range", min: 0, max: 30_000, value: nil}
    },
    visual_settings: %{
    },
    image_url: ""
  ]

  @impl true
  def handle_command(_params) do
    {:ok, ""}
  end

  @impl true
  def widget_type() do
    @widget_type
  end

  @impl true
  def widget_parameters() do
    Map.from_struct(__MODULE__)
  end

  @impl true
  def widget_name() do
    @widget_name
  end
end
