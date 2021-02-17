defmodule AcqdatApiWeb.DashboardManagement.CommandWidgetControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.DashboardManagement.Schema.CommandWidget

  describe "command_widget_types/2 " do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      [org: org]
    end

    test "returns a list of command_widget types", context do
      %{org: org, conn: conn} = context

      result =
        get(conn, Routes.command_widget_path(conn, :command_widget_types, org.id))
        |> json_response(200)

      assert Map.has_key?(result, "command_widget_types")
    end
  end

  describe "create/2 " do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      panel = insert(:panel, org: org)
      gateway = insert(:gateway, org: org)

      [gateway: gateway, panel: panel, org: org]
    end

    test "creates a command widget", context do
      %{gateway: gateway, panel: panel, conn: conn, org: org} = context
      module = "Elixir.AcqdatCore.DashboardManagement.Schema.CommandWidget.LEDControl"
      data_settings = setup_data()

      params = %{
        "gateway_id" => gateway.id,
        "panel_id" => panel.id,
        "module" => module,
        "data_settings" => data_settings,
        "visual_settings" => %{},
        "label" => "LED Control Panel"
      }

      result =
        conn
        |> post(
          Routes.command_widget_path(conn, :create, org.id, panel.id),
          params
        )
        |> json_response(200)

      assert result["label"] == params["label"]
      assert result["gateway_id"] == params["gateway_id"]
    end

    test "fails if error", context do
      %{panel: panel, conn: conn, org: org} = context
      module = "Elixir.AcqdatCore.DashboardManagement.Schema.CommandWidget.LEDControl"
      data_settings = setup_data()

      params = %{
        "gateway_id" => -1,
        "panel_id" => panel.id,
        "module" => module,
        "data_settings" => data_settings,
        "visual_settings" => %{},
        "label" => "LED Control Panel"
      }

      result =
        conn
        |> post(
          Routes.command_widget_path(conn, :create, org.id, panel.id),
          params
        )
        |> json_response(400)

      assert %{
               "detail" =>
                 "Parameters provided to perform current action is either not valid or missing or not unique",
               "source" => %{"gateway" => ["does not exist"]},
               "status_code" => 400,
               "title" => "Insufficient or not unique parameters"
             } == result
    end
  end

  describe "update/2 " do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      panel = insert(:panel, org: org)
      gateway = insert(:gateway, org: org)

      [gateway: gateway, panel: panel, org: org]
    end

    test "update data settings", context do
      %{panel: panel, conn: conn, org: org} = context
      command_widget = insert(:command_widget)
      data_settings = setup_data()
      params = %{"data_settings" => data_settings}

      result =
        put(
          conn,
          Routes.command_widget_path(conn, :update, org.id, panel.id, command_widget.id),
          params
        )
        |> json_response(200)

      assert command_widget.data_settings != result["data_settings"]
    end
  end

  describe "delete/2 " do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      panel = insert(:panel, org: org)

      [panel: panel, org: org]
    end

    test "deletes a command widget", context do
      %{org: org, panel: panel, conn: conn} = context
      command_widget = insert(:command_widget)

      delete(
        conn,
        Routes.command_widget_path(conn, :delete, org.id, panel.id, command_widget.id)
      )
      |> json_response(200)

      response = Repo.get(CommandWidget, command_widget.id)
      assert response == nil
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
