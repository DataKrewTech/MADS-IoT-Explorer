defmodule AcqdatCore.Model.DashboardManagement.CommandWidgetTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.DashboardManagement.CommandWidget

  describe "create/1 " do
    setup do
      dashboard = insert(:dashboard)
      gateway = insert(:gateway)

      [gateway: gateway, dashboard: dashboard]
    end

    test "creates a command widget with supplied params", context do
      %{gateway: gateway, dashboard: dasbhoard} = context
      module = "Elixir.AcqdatCore.DashboardManagement.Schema.CommandWidget.LEDControl"
      data_settings = setup_data()
      params = %{
        gateway_id: gateway.id, dashboard_id: dasbhoard.id, module: module,
        data_settings: data_settings, visual_settings: %{},
        label: "LED Control Panel"
      }

      assert {:ok, command_widget} = CommandWidget.create(params)
    end
  end

  describe "update/2 " do
    setup do
      dashboard = insert(:dashboard)
      gateway = insert(:gateway)

      [gateway: gateway, dashboard: dashboard]
    end

    test "update without data settings", context do
      %{gateway: gateway, dashboard: dasbhoard} = context
      module = "Elixir.AcqdatCore.DashboardManagement.Schema.CommandWidget.LEDControl"
      data_settings = setup_data()
      params = %{
        "gateway_id" => gateway.id, "dashboard_id" => dasbhoard.id, "module" => module,
        "data_settings" => data_settings, "visual_settings" => %{},
        "label" => "LED Control Panel"
      }
      {:ok, command_widget} = CommandWidget.create(params)

      update_params = %{"label" => "LED Panel"}
      assert {:ok, updated_command_widget} = CommandWidget.update(command_widget, update_params)
      assert updated_command_widget.id == command_widget.id
      refute updated_command_widget.label == command_widget.label
    end

    test "update with data settings", context do
      %{gateway: gateway, dashboard: dasbhoard} = context
      module = "Elixir.AcqdatCore.DashboardManagement.Schema.CommandWidget.LEDControl"
      data_settings = setup_data()
      params = %{
        "gateway_id" => gateway.id, "dashboard_id" => dasbhoard.id, "module" => module,
        "data_settings" => data_settings, "visual_settings" => %{},
        "label" => "LED Control Panel"
      }
      {:ok, command_widget} = CommandWidget.create(params)

      data = setup_data()
      update_params = %{"label" => "LED Panel", "data_settings" => data}
      {:ok, updated_command_widget} = CommandWidget.update(command_widget, update_params)

    end
  end

  defp setup_data() do
    %{
      rgb_mode: %{
        html_tag: "select",
        source: %{"off" => 0, "spectrum cycling" => 1, "breathing" => 2, "solid" => 3},
        default: 3,
        value: 1
      },
      w_mode: %{
        html_type: "select",
        source: %{"off" => 0, "breathing" => 1, "solid" => 2},
        default: 2,
        value: 2
      },
      rgb_color: %{html_tag: "input", html_type: "color", value: [0,12,23]},
      intensity: %{html_tag: "input", html_type: "range", min: 0, max: 255, value: 100},
      warm_white: %{html_tag: "input", html_type: "range", min: 0, max: 30_000, value: 100},
      cold_white: %{html_tag: "input", html_type: "range", min: 0, max: 30_000, value: 100}
    }
  end
end
