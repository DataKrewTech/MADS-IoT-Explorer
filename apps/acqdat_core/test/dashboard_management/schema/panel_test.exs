defmodule AcqdatCore.Schema.DashboardManagement.PanelTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.DashboardManagement.Schema.Panel

  describe "changeset/2" do
    setup do
      organisation = insert(:organisation)
      dashboard = insert(:dashboard)
      [organisation: organisation, dashboard: dashboard]
    end

    test "returns a valid changeset", context do
      %{organisation: organisation, dashboard: dashboard} = context

      params = %{
        name: "Demo Panel",
        org_id: organisation.id,
        dashboard_id: dashboard.id
      }

      %{valid?: validity} = Panel.changeset(%Panel{}, params)
      assert validity
    end

    test "returns invalid if params empty" do
      %{valid?: validity} = changeset = Panel.changeset(%Panel{}, %{})
      refute validity

      assert %{
               org_id: ["can't be blank"],
               dashboard_id: ["can't be blank"],
               name: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "returns error if Panel name is not presenet", %{
      organisation: organisation,
      dashboard: dashboard
    } do
      params = %{
        org_id: organisation.id,
        dashboard_id: dashboard.id
      }

      changeset = Panel.changeset(%Panel{}, params)

      {:error, result_changeset} = Repo.insert(changeset)
      assert %{name: ["can't be blank"]} == errors_on(result_changeset)
    end

    test "returns error if organisation assoc constraint not satisfied", %{
      dashboard: dashboard
    } do
      params = %{
        name: "Demo Panel",
        org_id: -1,
        dashboard_id: dashboard.id
      }

      changeset = Panel.changeset(%Panel{}, params)

      {:error, result_changeset} = Repo.insert(changeset)
      assert %{org: ["does not exist"]} == errors_on(result_changeset)
    end

    test "returns error if dashboard assoc constraint not satisfied", %{
      organisation: organisation
    } do
      params = %{
        name: "Demo Panel",
        org_id: organisation.id,
        dashboard_id: -1
      }

      changeset = Panel.changeset(%Panel{}, params)

      {:error, result_changeset} = Repo.insert(changeset)
      assert %{dashboard: ["does not exist"]} == errors_on(result_changeset)
    end

    test "returns error if unique name constraint not satisified under dashboard", %{
      organisation: organisation,
      dashboard: dashboard
    } do
      params = %{
        name: "Demo Panel",
        org_id: organisation.id,
        dashboard_id: dashboard.id
      }

      changeset = Panel.changeset(%Panel{}, params)

      Repo.insert(changeset)

      new_changeset = Panel.changeset(%Panel{}, params)
      {:error, result_changeset} = Repo.insert(new_changeset)
      assert %{name: ["unique panel name under dashboard"]} == errors_on(result_changeset)
    end
  end
end
