defmodule AcqdatCore.Schema.DashboardManagement.WidgetInstanceTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.DashboardManagement.Schema.WidgetInstance

  describe "changeset/2" do
    setup do
      widget = insert(:widget)
      panel = insert(:panel)
      [widget: widget, panel: panel]
    end

    test "returns a valid changeset", context do
      %{widget: widget, panel: panel} = context

      params = %{
        label: "Demo WidgetInstance",
        widget_id: widget.id,
        panel_id: panel.id
      }

      %{valid?: validity} = WidgetInstance.changeset(%WidgetInstance{}, params)
      assert validity
    end

    test "returns invalid if params empty" do
      %{valid?: validity} = changeset = WidgetInstance.changeset(%WidgetInstance{}, %{})
      refute validity

      assert %{
               panel_id: ["can't be blank"],
               label: ["can't be blank"],
               widget_id: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "returns error if label is not presenet", %{widget: widget, panel: panel} do
      params = %{
        widget_id: widget.id,
        panel_id: panel.id
      }

      changeset = WidgetInstance.changeset(%WidgetInstance{}, params)

      {:error, result_changeset} = Repo.insert(changeset)
      assert %{label: ["can't be blank"]} == errors_on(result_changeset)
    end

    test "returns error if widget assoc constraint not satisfied", %{panel: panel} do
      params = %{
        label: "Demo WidgetInstance",
        widget_id: -1,
        panel_id: panel.id
      }

      changeset = WidgetInstance.changeset(%WidgetInstance{}, params)

      {:error, result_changeset} = Repo.insert(changeset)
      assert %{widget: ["does not exist"]} == errors_on(result_changeset)
    end

    test "returns error if panel assoc constraint not satisfied", %{widget: widget} do
      params = %{
        label: "Demo WidgetInstance",
        widget_id: widget.id,
        panel_id: -1
      }

      changeset = WidgetInstance.changeset(%WidgetInstance{}, params)

      {:error, result_changeset} = Repo.insert(changeset)
      assert %{panel: ["does not exist"]} == errors_on(result_changeset)
    end

    test "returns error if unique label constraint not satisified", %{
      widget: widget,
      panel: panel
    } do
      params = %{
        label: "Demo WidgetInstance",
        widget_id: widget.id,
        panel_id: panel.id
      }

      changeset = WidgetInstance.changeset(%WidgetInstance{}, params)

      Repo.insert(changeset)

      new_changeset = WidgetInstance.changeset(%WidgetInstance{}, params)
      {:error, result_changeset} = Repo.insert(new_changeset)

      assert %{label: ["unique widget label under dashboard's panel"]} ==
               errors_on(result_changeset)
    end
  end
end
