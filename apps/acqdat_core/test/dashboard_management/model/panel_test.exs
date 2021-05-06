defmodule AcqdatCore.Model.DashboardManagement.PanelTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.DashboardManagement.Panel, as: PanelModel
  alias AcqdatCore.DashboardManagement.Schema.WidgetInstance
  alias AcqdatCore.Model.DashboardManagement.WidgetInstance, as: WidgetInstanceModel

  describe "get_by_id/1" do
    test "returns a particular panel" do
      panel = insert(:panel)
      {:ok, result} = PanelModel.get_by_id(panel.id)

      assert not is_nil(result)
      assert result.id == panel.id
    end

    test "returns error not found, if panel is not present" do
      {:error, result} = PanelModel.get_by_id(-1)
      assert result == "panel with this id not found"
    end
  end

  describe "get_with_widgtes/1" do
    test "returns a particular panel with its widgets" do
      widget_instance = insert(:widget_instance)
      {:ok, result} = PanelModel.get_with_widgets(widget_instance.panel_id)

      assert not is_nil(result)
      assert result.id == widget_instance.panel_id
      assert not is_nil(length(result.widgets))
    end

    test "returns a particular panel widgets with from_date and to_date selected on the basis of last filter_metadata" do
      panel = insert(:panel, filter_metadata: %{last: "15_day"})
      widget_instance = build(:widget_instance, panel: panel)
      {:ok, widget_instance1} = Repo.insert(widget_instance)
      {:ok, result} = PanelModel.get_with_widgets(widget_instance1.panel_id)

      assert not is_nil(result)
      assert result.id == widget_instance1.panel_id
      assert not is_nil(length(result.widgets))
    end

    test "returns a particular panel widgets with from_date and to_date set by user" do
      panel = insert(:panel, filter_metadata: %{last: "custom"})
      widget_instance = build(:widget_instance, panel: panel)
      {:ok, widget_instance1} = Repo.insert(widget_instance)
      {:ok, result} = PanelModel.get_with_widgets(widget_instance1.panel_id)

      assert not is_nil(result)
      assert result.id == widget_instance1.panel_id
      assert not is_nil(length(result.widgets))
    end

    test "returns error not found, if panel is not present" do
      {:error, result} = PanelModel.get_with_widgets(-1)
      assert result == "panel with this id not found"
    end
  end

  describe "create/1" do
    setup do
      organisation = insert(:organisation)
      dashboard = insert(:dashboard)
      [organisation: organisation, dashboard: dashboard]
    end

    test "creates a panel with supplied params", context do
      %{organisation: organisation, dashboard: dashboard} = context

      params = %{
        name: "Demo panel",
        icon: "demo",
        org_id: organisation.id,
        dashboard_id: dashboard.id
      }

      assert {:ok, _panel} = PanelModel.create(params)
    end

    test "fails if organisation_id is not present", %{dashboard: dashboard} do
      params = %{
        name: "Demo panel",
        dashboard_id: dashboard.id,
        icon: "home"
      }

      assert {:error, changeset} = PanelModel.create(params)
      assert %{org_id: ["can't be blank"]} == errors_on(changeset)
    end

    test "fails if dashboard_id is not present", %{organisation: organisation} do
      params = %{
        name: "Demo panel",
        icon: "demo",
        org_id: organisation.id
      }

      assert {:error, changeset} = PanelModel.create(params)
      assert %{dashboard_id: ["can't be blank"]} == errors_on(changeset)
    end

    test "fails if name is not present", context do
      %{organisation: organisation, dashboard: dashboard} = context

      params = %{
        org_id: organisation.id,
        dashboard_id: dashboard.id
      }

      assert {:error, changeset} = PanelModel.create(params)
      assert %{name: ["can't be blank"]} == errors_on(changeset)
    end
  end

  describe "update/1" do
    setup do
      panel = insert(:panel)
      [panel: panel]
    end

    test "updates a panel with supplied params", context do
      %{panel: panel} = context

      params = %{
        name: "updated Demo panel"
      }

      assert {:ok, _panel} = PanelModel.update(panel, params)
    end
  end

  describe "delete_all/1" do
    test "deletes a particular panel and its associated widgets" do
      panel = insert(:panel)
      widget = insert(:widget)

      {:ok, widget_inst} =
        WidgetInstanceModel.create(%{
          label: "widget_instance",
          panel_id: panel.id,
          widget_id: widget.id
        })

      {no_of_deleted_records, _} = PanelModel.delete_all([panel.id])

      widget_instance = Repo.get(WidgetInstance, widget_inst.id)

      assert no_of_deleted_records == 1
      assert is_nil(widget_instance)
    end
  end

  describe "delete/1" do
    test "deletes a particular panel and its associated widgets" do
      panel = insert(:panel)
      widget = insert(:widget)

      {:ok, widget_inst} =
        WidgetInstanceModel.create(%{
          label: "widget_instance",
          panel_id: panel.id,
          widget_id: widget.id
        })

      {:ok, result} = PanelModel.delete(panel)
      assert not is_nil(result)
      assert result.id == panel.id

      widget_instance = Repo.get(WidgetInstance, widget_inst.id)

      assert is_nil(widget_instance)
    end
  end
end
