defmodule AcqdatCore.Schema.DataInsights.FactTablesTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.DataInsights.Schema.FactTables

  describe "changeset/2" do
    setup do
      organisation = insert(:organisation)
      project = insert(:project)
      creator = insert(:user)
      [organisation: organisation, project: project, creator: creator]
    end

    test "returns a valid changeset", context do
      %{organisation: organisation, project: project, creator: creator} = context

      params = %{
        name: "Demo FactTable",
        org_id: organisation.id,
        project_id: project.id,
        creator_id: creator.id
      }

      %{valid?: validity} = FactTables.changeset(%FactTables{}, params)
      assert validity
    end

    test "returns invalid if params empty" do
      %{valid?: validity} = changeset = FactTables.changeset(%FactTables{}, %{})
      refute validity

      assert %{
               name: ["can't be blank"],
               org_id: ["can't be blank"],
               creator_id: ["can't be blank"],
               project_id: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "returns error if FactTables name is not present", %{
      organisation: organisation,
      project: project,
      creator: creator
    } do
      params = %{
        org_id: organisation.id,
        project_id: project.id,
        creator_id: creator.id
      }

      changeset = FactTables.changeset(%FactTables{}, params)

      {:error, result_changeset} = Repo.insert(changeset)
      assert %{name: ["can't be blank"]} == errors_on(result_changeset)
    end

    test "returns error if organisation assoc constraint not satisfied", %{
      project: project,
      creator: creator
    } do
      params = %{
        name: "Demo FactTable",
        org_id: -1,
        project_id: project.id,
        creator_id: creator.id
      }

      changeset = FactTables.changeset(%FactTables{}, params)

      {:error, result_changeset} = Repo.insert(changeset)
      assert %{org: ["does not exist"]} == errors_on(result_changeset)
    end

    test "returns error if project assoc constraint not satisfied", %{
      organisation: organisation,
      creator: creator
    } do
      params = %{
        name: "Demo FactTable",
        org_id: organisation.id,
        project_id: -1,
        creator_id: creator.id
      }

      changeset = FactTables.changeset(%FactTables{}, params)

      {:error, result_changeset} = Repo.insert(changeset)
      assert %{project: ["does not exist"]} == errors_on(result_changeset)
    end

    test "returns error if creator assoc constraint not satisfied", %{
      organisation: organisation,
      project: project
    } do
      params = %{
        name: "Demo FactTable",
        org_id: organisation.id,
        project_id: project.id,
        creator_id: -1
      }

      changeset = FactTables.changeset(%FactTables{}, params)

      {:error, result_changeset} = Repo.insert(changeset)
      assert %{creator: ["does not exist"]} == errors_on(result_changeset)
    end

    test "returns error if unique name constraint not satisified under project", %{
      organisation: organisation,
      project: project,
      creator: creator
    } do
      params = %{
        name: "Demo FactTable",
        org_id: organisation.id,
        project_id: project.id,
        creator_id: creator.id
      }

      changeset = FactTables.changeset(%FactTables{}, params)

      Repo.insert(changeset)

      new_changeset = FactTables.changeset(%FactTables{}, params)
      {:error, result_changeset} = Repo.insert(new_changeset)
      assert %{name: ["unique fact table name under a project"]} == errors_on(result_changeset)
    end
  end
end
