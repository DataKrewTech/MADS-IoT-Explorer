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
      %{gateway: gateway, dashboard: dashboard} = context
      module = "Elixir.AcqdatCore.DashboardManagement.Schema.CommandWidget.LEDControl"
      data_settings = setup_data()

      params = %{
        gateway_id: gateway.id,
        dashboard_id: dashboard.id,
        module: module,
        data_settings: data_settings,
        visual_settings: %{},
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
        "gateway_id" => gateway.id,
        "dashboard_id" => dasbhoard.id,
        "module" => module,
        "data_settings" => data_settings,
        "visual_settings" => %{},
        "label" => "LED Control Panel"
      }

      {:ok, command_widget} = CommandWidget.create(params)

      update_params = %{"label" => "LED Panel"}
      assert {:ok, updated_command_widget} = CommandWidget.update(command_widget, update_params)
      assert updated_command_widget.id == command_widget.id
      refute updated_command_widget.label == command_widget.label
    end

    # TODO add mock for mqtt
    test "update with data settings", context do
      %{gateway: gateway, dashboard: dasbhoard} = context
      module = "Elixir.AcqdatCore.DashboardManagement.Schema.CommandWidget.LEDControl"
      data_settings = setup_data()

      params = %{
        "gateway_id" => gateway.id,
        "dashboard_id" => dasbhoard.id,
        "module" => module,
        "data_settings" => data_settings,
        "visual_settings" => %{},
        "label" => "LED Control Panel"
      }

      {:ok, command_widget} = CommandWidget.create(params)

      data = setup_data()
      update_params = %{"label" => "LED Panel", "data_settings" => data}
      {:ok, updated_command_widget} = CommandWidget.update(command_widget, update_params)
      assert updated_command_widget.id == command_widget.id
      assert updated_command_widget.label != command_widget.label
    end
  end

  describe "get/1 " do
    setup do
      dashboard = insert(:dashboard)
      command_widgets = insert_list(3, :command_widget, dashboard: dashboard)
      [command_widgets: command_widgets]
    end

    test "command widget by id", context do
      %{command_widgets: [cw1, _cw_2, _cw_3]} = context
      {:ok, widget} = CommandWidget.get(cw1.id)
      assert widget.id == cw1.id
    end

    test "command widget by uuid", context do
      %{command_widgets: [cw1, _cw_2, _cw_3]} = context
      {:ok, widget} = CommandWidget.get(%{uuid: cw1.uuid})
      assert widget.id == cw1.id
    end
  end

  describe "get_all_by_dashboard_id/1 " do
    setup do
      dashboard = insert(:dashboard)
      command_widgets = insert_list(3, :command_widget, dashboard: dashboard)
      [command_widgets: command_widgets]
    end

    test "returns command widget with id", context do
      %{command_widgets: [cw1, _cw_2, _cw_3]} = context
      widgets = CommandWidget.get_all_by_dashboard_id(cw1.dashboard_id)
      assert length(widgets) == 3
    end

    test "returns empty if none found" do
      dashboard = insert(:dashboard)
      widgets = CommandWidget.get_all_by_dashboard_id(dashboard.id)
      assert widgets == []
    end
  end

  describe "delete/1" do
    test "deletes a command widget" do
      command_widget = insert(:command_widget)
      assert {:ok, _result} = CommandWidget.delete(command_widget)
      assert {:error, "Command Widget not found"} == CommandWidget.get(command_widget.id)
    end
  end

  defp setup_data() do
    %{
      "rgb_mode" => %{
        "html_tag" => "select",
        "source" => %{"off" => 0, "spectrum cycling" => 1, "breathing" => 2, "solid" => 3},
        "default" => 3,
        "value" => 1
      },
      "w_mode" => %{
        "html_type" => "select",
        "source" => %{"off" => 0, "breathing" => 1, "solid" => 2},
        "default" => 2,
        "value" => 2
      },
      "rgb_color" => %{"html_tag" => "input", "html_type" => "color", "value" => [0, 12, 23]},
      "intensity" => %{
        "html_tag" => "input",
        "html_type" => "range",
        "min" => 0,
        "max" => 255,
        "value" => 100
      },
      "warm_white" => %{
        "html_tag" => "input",
        "html_type" => "range",
        "min" => 0,
        "max" => 30_000,
        "value" => 100
      },
      "cold_white" => %{
        "html_tag" => "input",
        "html_type" => "range",
        "min" => 0,
        "max" => 30_000,
        "value" => 100
      }
    }
  end
end
