defmodule AcqdatCore.Schema.DashboardManagement.DashboardTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.DashboardManagement.Schema.Dashboard

  describe "changeset/2" do
    setup do
      organisation = insert(:organisation)
      project = insert(:project)
      [organisation: organisation, project: project]
    end

    test "returns a valid changeset", context do
      %{organisation: organisation, project: project} = context

      params = %{
        name: "Demo Dashboard",
        org_id: organisation.id,
        project_id: project.id
      }

      %{valid?: validity} = Dashboard.changeset(%Dashboard{}, params)
      assert validity
    end

    test "returns invalid if params empty" do
      %{valid?: validity} = changeset = Dashboard.changeset(%Dashboard{}, %{})
      refute validity

      assert %{
               org_id: ["can't be blank"],
               name: ["can't be blank"],
               project_id: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "returns error if dashboard name is not presenet", %{
      project: project,
      organisation: organisation
    } do
      params = %{
        org_id: organisation.id,
        project_id: project.id
      }

      changeset = Dashboard.changeset(%Dashboard{}, params)

      {:error, result_changeset} = Repo.insert(changeset)
      assert %{name: ["can't be blank"]} == errors_on(result_changeset)
    end

    test "returns error if organisation assoc constraint not satisfied", %{project: project} do
      params = %{
        name: "Demo Dashboard",
        org_id: -1,
        project_id: project.id
      }

      changeset = Dashboard.changeset(%Dashboard{}, params)

      {:error, result_changeset} = Repo.insert(changeset)
      assert %{org: ["does not exist"]} == errors_on(result_changeset)
    end

    test "returns error if project assoc constraint not satisfied", %{organisation: organisation} do
      params = %{
        uuid: UUID.uuid1(:hex),
        name: "Temperature",
        org_id: organisation.id
      }

      changeset = Dashboard.changeset(%Dashboard{}, params)

      {:error, result_changeset} = Repo.insert(changeset)

      assert %{project_id: ["can't be blank"]} ==
               errors_on(result_changeset)
    end

    test "returns error if unique name constraint not satisified", %{
      project: project,
      organisation: organisation
    } do
      params = %{
        name: "Demo Dashboard",
        org_id: organisation.id,
        project_id: project.id
      }

      changeset = Dashboard.changeset(%Dashboard{}, params)

      Repo.insert(changeset)

      new_changeset = Dashboard.changeset(%Dashboard{}, params)
      {:error, result_changeset} = Repo.insert(new_changeset)
      assert %{name: ["unique name under project"]} == errors_on(result_changeset)
    end
  end
end
