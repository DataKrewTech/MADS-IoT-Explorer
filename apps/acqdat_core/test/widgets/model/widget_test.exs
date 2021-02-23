defmodule AcqdatCore.Model.Widgets.WidgetTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory

  alias AcqdatCore.Model.Widgets.Widget

  describe "get/1" do
    test "returns a particular widget by id" do
      widget = insert(:widget)

      {:ok, result} = Widget.get(widget.id)
      assert not is_nil(result)
      assert result.id == widget.id
    end

    test "returns error not found, if widget is not present" do
      {:error, result} = Widget.get(-1)
      assert result == "not found"
    end
  end

  describe "get_by_label/1" do
    test "returns a particular widget by id" do
      widget = insert(:widget)

      {:ok, result} = Widget.get_by_label(widget.label)
      assert not is_nil(result)
      assert result.label == widget.label
    end

    test "returns error not found, if widget is not present" do
      {:error, result} = Widget.get_by_label("demo dfr")
      assert result == "not found"
    end
  end

  describe "create/1" do
    setup do
      widget_type = insert(:widget_type)

      [widget_type: widget_type]
    end

    test "creates a widget with valid supplied params", %{widget_type: widget_type} do
      params = %{
        label: "line widget",
        widget_type_id: widget_type.id,
        default_values: %{
          "data_settings_values" => %{
            "series" => []
          },
          "visual_setting_values" => %{
            "rangeSelector" => %{
              "selected" => 1
            },
            "title" => %{
              "text" => "AAPL Stock Price"
            }
          }
        }
      }

      assert {:ok, widget} = Widget.create(params)
      assert widget.label == "line widget"
    end

    test "fails if widget_type_id is not present" do
      params = %{
        label: "line widget",
        default_values: %{
          "data_settings_values" => %{
            "series" => []
          },
          "visual_setting_values" => %{
            "rangeSelector" => %{
              "selected" => 1
            },
            "title" => %{
              "text" => "AAPL Stock Price"
            }
          }
        }
      }

      assert {:error, changeset} = Widget.create(params)
      assert %{widget_type_id: ["can't be blank"]} == errors_on(changeset)
    end

    test "fails if label is not present", %{widget_type: widget_type} do
      params = %{
        widget_type_id: widget_type.id,
        default_values: %{
          "data_settings_values" => %{
            "series" => []
          },
          "visual_setting_values" => %{
            "rangeSelector" => %{
              "selected" => 1
            },
            "title" => %{
              "text" => "AAPL Stock Price"
            }
          }
        }
      }

      assert {:error, changeset} = Widget.create(params)
      assert %{label: ["can't be blank"]} == errors_on(changeset)
    end
  end

  describe "get_all_by_classification_not_standard/1" do
    setup do
      widget = insert(:widget)
      gauge = insert(:widget, classification: "gauge")
      standard = insert(:widget, classification: "standard")

      [widget: widget, gauge: gauge, standard: standard]
    end

    test "should not list standard type classification", %{widget: _widget} do
      grouped = Widget.get_all_by_classification_not_standard(%{})
      res = Enum.map(grouped, fn x -> x.classification end)
      assert Enum.sort(res) == ["gauge", "timeseries"]
    end
  end

  describe "get_all_by_classification/1" do
    setup do
      widget = insert(:widget)
      gauge = insert(:widget, classification: "gauge")
      standard = insert(:widget, classification: "standard")

      [widget: widget, gauge: gauge, standard: standard]
    end

    test "should not list standard type classification", %{widget: _widget} do
      grouped = Widget.get_all_by_classification(%{})
      res = Enum.map(grouped, fn x -> x.classification end)
      assert Enum.sort(res) == ["gauge", "standard", "timeseries"]
    end
  end

  describe "update/2" do
    setup do
      widget = insert(:widget)

      [widget: widget]
    end

    test "updating widget name/params will name", %{widget: widget} do
      assert {:ok, result} = Widget.update(widget, %{"label" => "updated widget name"})
      assert result.label == "updated widget name"
    end
  end

  describe "delete/1" do
    setup do
      widget = insert(:widget)

      [widget: widget]
    end

    test "successfully delete widget", %{widget: widget} do
      assert {:ok, result} = Widget.delete(widget)
      assert result.id == widget.id
    end
  end
end
