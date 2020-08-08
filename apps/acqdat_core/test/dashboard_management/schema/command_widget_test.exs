defmodule AcqdatCore.DashboardManagement.Schema.CommandWidgetTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.DashboardManagement.Schema.CommandWidget

  describe "changeset" do
    setup do
      dashboard = insert(:dashboard)
      gateway = insert(:gateway)

      [gateway: gateway, dashboard: dashboard]
    end

    test "returns a valid changeset", context do
      %{dashboard: dashboard, gateway: gateway} = context
      module = "Elixir.AcqdatCore.DashboardManagement.Schema.CommandWidget.LEDControl"

      params = %{
        label: "LED CONTROL WIDGET",
        module: module,
        gateway_id: gateway.id,
        dashboard_id: dashboard.id
      }

      %{valid?: validity} = CommandWidget.changeset(%CommandWidget{}, params)
      assert validity
    end

    test "returns invalid for missing params" do
      params = %{}
      changeset = CommandWidget.changeset(%CommandWidget{}, params)

      assert errors_on(changeset) == %{
               dashboard_id: ["can't be blank"],
               gateway_id: ["can't be blank"],
               label: ["can't be blank"],
               module: ["can't be blank"]
             }
    end

    test "fails for invalid associations", context do
      %{dashboard: dashboard, gateway: gateway} = context
      module = "Elixir.AcqdatCore.DashboardManagement.Schema.CommandWidget.LEDControl"

      params = %{
        label: "LED CONTROL WIDGET",
        module: module,
        gateway_id: -1,
        dashboard_id: dashboard.id
      }

      changeset = CommandWidget.changeset(%CommandWidget{}, params)

      {:error, changeset} = Repo.insert(changeset)
      assert errors_on(changeset) == %{gateway: ["does not exist"]}

      params = %{
        label: "LED CONTROL WIDGET",
        module: module,
        gateway_id: gateway.id,
        dashboard_id: -1
      }

      changeset = CommandWidget.changeset(%CommandWidget{}, params)

      {:error, changeset} = Repo.insert(changeset)
      assert errors_on(changeset) == %{dashboard: ["does not exist"]}
    end
  end
end
