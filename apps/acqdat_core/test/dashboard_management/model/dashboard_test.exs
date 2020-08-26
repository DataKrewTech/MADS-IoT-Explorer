defmodule AcqdatCore.Model.DashboardManagement.DashboardTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.DashboardManagement.Dashboard, as: DashboardModel
  alias AcqdatCore.DashboardManagement.Schema.Panel
  alias AcqdatCore.Model.DashboardManagement.Panel, as: PanelModel

  describe "get_by_id/1" do
    test "returns a particular dashboard" do
      dashboard = insert(:dashboard)
      {:ok, result} = DashboardModel.get_by_id(dashboard.id)

      assert not is_nil(result)
      assert result.id == dashboard.id
    end

    test "returns error not found, if dashboard is not present" do
      {:error, result} = DashboardModel.get_by_id(-1)
      assert result == "dashboard with this id not found"
    end
  end

  describe "get_with_panels/1" do
    test "returns a particular dashboard with its panels" do
      panel = insert(:panel)
      {:ok, result} = DashboardModel.get_with_panels(panel.dashboard_id)

      assert not is_nil(result)
      assert result.id == panel.dashboard_id
      assert not is_nil(length(result.panels))
    end

    test "returns error not found, if dashboard is not present" do
      {:error, result} = DashboardModel.get_with_panels(-1)
      assert result == "dashboard with this id not found"
    end
  end

  describe "get_all/1" do
    test "returns all dashboards" do
      dashboard = insert(:dashboard)

      result =
        DashboardModel.get_all(%{
          page_size: 10,
          page_number: 1,
          org_id: dashboard.org_id
        })

      assert not is_nil(result)
      assert length(result.entries) == 1
    end
  end

  describe "create/1" do
    setup do
      organisation = insert(:organisation)
      [organisation: organisation]
    end

    test "creates a dashboard with supplied params", context do
      %{organisation: organisation} = context

      params = %{
        name: "Demo Dashboard",
        org_id: organisation.id
      }

      assert {:ok, _dashboard} = DashboardModel.create(params)
    end

    test "fails if organisation_id is not present", context do
      params = %{
        name: "Demo Dashboard"
      }

      assert {:error, changeset} = DashboardModel.create(params)
      assert %{org_id: ["can't be blank"]} == errors_on(changeset)
    end

    test "fails if name is not present", context do
      %{organisation: organisation} = context

      params = %{
        org_id: organisation.id
      }

      assert {:error, changeset} = DashboardModel.create(params)
      assert %{name: ["can't be blank"]} == errors_on(changeset)
    end
  end

  describe "update/1" do
    setup do
      dashboard = insert(:dashboard)
      [dashboard: dashboard]
    end

    test "creates a dashboard with supplied params", context do
      %{dashboard: dashboard} = context

      params = %{
        name: "updated Demo Dashboard"
      }

      assert {:ok, _dashboard} = DashboardModel.update(dashboard, params)
    end
  end

  describe "delete/1" do
    test "deletes a particular dashboard and its associated panels" do
      dashboard = insert(:dashboard)
      widget = insert(:widget)

      {:ok, panel} =
        PanelModel.create(%{
          name: "Home",
          dashboard_id: dashboard.id,
          widget_id: widget.id,
          org_id: dashboard.org_id
        })

      {:ok, result} = DashboardModel.delete(dashboard)

      panel = Repo.get(Panel, panel.id)

      assert not is_nil(result)
      assert result.id == dashboard.id
      assert is_nil(panel)
    end
  end
end
