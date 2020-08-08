defmodule AcqdatCore.DashboardManagement.Schema.CommandWidget.LEDControl do
  @moduledoc """
  Adds schema and controls for LEDControl Widget.
  """
  use AcqdatCore.Schema
  alias AcqdatCore.Model.IotManager.Gateway
  @behaviour AcqdatCore.DashboardManagement.Schema.CommandWidget
  @widget_type "html"
  @widget_name "LED Control"

  defstruct gateway: nil,
            data_settings: %{
              rgb_mode: %{
                html_tag: "select",
                source: %{"off" => 0, "spectrum cycling" => 1, "breathing" => 2, "solid" => 3},
                default: 3,
                value: nil
              },
              w_mode: %{
                html_tag: "select",
                source: %{"off" => 0, "breathing" => 1, "solid" => 2},
                default: 2,
                value: nil
              },
              rgb_color: %{html_tag: "input", html_type: "color", value: nil},
              intensity: %{html_tag: "input", html_type: "range", min: 0, max: 255, value: nil},
              warm_white: %{
                html_tag: "input",
                html_type: "range",
                min: 0,
                max: 30_000,
                value: nil
              },
              cold_white: %{
                html_tag: "input",
                html_type: "range",
                min: 0,
                max: 30_000,
                value: nil
              }
            },
            visual_settings: %{},
            image_url: ""

  @impl true
  # TODO: Handles only mqtt need to handle http
  def handle_command(command_widget, _options \\ []) do
    data =
      command_widget.data_settings
      |> Enum.reduce(%{}, fn
        {"rgb_color", value}, acc ->
          acc
          |> Map.put(:red, Enum.at(value["value"], 0))
          |> Map.put(:green, Enum.at(value["value"], 1))
          |> Map.put(:blue, Enum.at(value["value"], 2))

        {key, value}, acc ->
          Map.put(acc, key, value["value"])
      end)

    prepare_payload_and_send(command_widget, data)
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

  @impl true
  def image_url() do
    ""
  end

  defp prepare_payload_and_send(command_widget, data) do
    actuator_payload = Map.put(%{}, :actuator, data)
    current_timestamp = DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_unix()

    data_payload =
      %{}
      |> Map.put(:data, actuator_payload)
      |> Map.put(:timestamp, current_timestamp)
      |> Map.put(:gateway_id, command_widget.gateway_id)
      |> Map.put(:project_id, command_widget.gateway.project_id)
      |> Map.put(:org_id, command_widget.gateway.org_id)

    Gateway.send_mqtt_command(command_widget.gateway, data_payload)
    {:ok, "Command Sent"}
  end
end
