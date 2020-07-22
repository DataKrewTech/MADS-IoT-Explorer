defmodule AcqdatCore.Model.DashboardManagement.WidgetInstanceTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.DashboardManagement.WidgetInstance, as: WidgetInstanceModel
  alias AcqdatCore.DashboardManagement.Schema.WidgetInstance
  alias AcqdatCore.Model.EntityManagement.SensorData, as: SensorDataModel

  describe "get_by_filter" do
    setup do
      sensor = insert(:sensor)

      params = %{
        parameters: [
          %{data_type: "string", name: "Soil Humidity", value: "56"},
          %{data_type: "string", name: "Soil Humidity", value: "45"}
        ],
        inserted_timestamp: DateTime.utc_now(),
        sensor_id: sensor.id,
        org_id: sensor.org_id
      }

      SensorDataModel.create(params)
      [sensor: sensor]
    end

    test "returns a particular widget_instance" do
      widget_instance = insert(:widget_instance)
      {:ok, result} = WidgetInstanceModel.get_by_filter(widget_instance.id)

      assert not is_nil(result)
      assert result.id == widget_instance.id
    end

    test "returns respective widget by filtered data", %{sensor: sensor} do
      series_data = [
        %{
          name: "jane",
          color: "#ffffff",
          axes: [
            %{
              name: "y",
              source_type: "pds",
              source_metadata: %{
                entity_type: "sensor",
                entity_id: sensor.id,
                parameter: "Soil Humidity"
              }
            },
            %{
              name: "x",
              source_type: "pds",
              source_metadata: %{
                entity_type: "sensor",
                entity_id: sensor.id,
                parameter: "inserted_timestamp"
              }
            }
          ]
        }
      ]

      widget_instance = build(:widget_instance, series_data: series_data)
      {:ok, res} = Repo.insert(widget_instance)
      {:ok, result} = WidgetInstanceModel.get_by_filter(res.id)
      assert not is_nil(result)
      assert not is_nil(length(result.series))
    end

    test "returns error not found, if widget_instance is not present" do
      {:error, result} = WidgetInstanceModel.get_by_filter(-1)
      assert result == "widget instance with this id not found"
    end
  end

  describe "get_all_by_dashboard_id" do
    test "returns all widget_instances of respective dashboard" do
      widget = insert(:widget_instance)
      result = WidgetInstanceModel.get_all_by_dashboard_id(widget.dashboard_id)

      assert not is_nil(result)
      assert length(result) == 1
    end
  end

  describe "create/1" do
    setup do
      dashboard = insert(:dashboard)
      widget = insert(:widget)
      [dashboard: dashboard, widget: widget]
    end

    test "creates a widget_instance with supplied params", context do
      %{dashboard: dashboard, widget: widget} = context

      params = %{
        label: "Demo WidgetInstance",
        widget_id: widget.id,
        dashboard_id: dashboard.id
      }

      assert {:ok, _widget_instance} = WidgetInstanceModel.create(params)
    end

    test "fails if dashboard_id is not present", context do
      %{widget: widget} = context

      params = %{
        label: "Demo WidgetInstance",
        widget_id: widget.id
      }

      assert {:error, changeset} = WidgetInstanceModel.create(params)
      assert %{dashboard_id: ["can't be blank"]} == errors_on(changeset)
    end

    test "fails if label is not present", context do
      %{dashboard: dashboard, widget: widget} = context

      params = %{
        widget_id: widget.id,
        dashboard_id: dashboard.id
      }

      assert {:error, changeset} = WidgetInstanceModel.create(params)
      assert %{label: ["can't be blank"]} == errors_on(changeset)
    end

    test "fails if widget is not present", context do
      %{dashboard: dashboard} = context

      params = %{
        label: "Demo WidgetInstance",
        dashboard_id: dashboard.id
      }

      assert {:error, changeset} = WidgetInstanceModel.create(params)
      assert %{widget_id: ["can't be blank"]} == errors_on(changeset)
    end
  end

  describe "delete/1" do
    test "deletes a particular widget_instance" do
      widget_instance = insert(:widget_instance)

      {:ok, result} = WidgetInstanceModel.delete(widget_instance)

      assert not is_nil(result)
      assert result.id == widget_instance.id
    end
  end
end
