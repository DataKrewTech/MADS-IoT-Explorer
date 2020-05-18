defmodule AcqdatCore.Schema.EntityManagement.ProjectTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory

  alias AcqdatCore.Schema.EntityManagement.Project

  describe "changeset/2" do
    setup do
      org = insert(:organisation)
      creator = insert(:user)

      [org: org, creator: creator]
    end

    test "returns error changeset on empty params" do
      changeset = Project.changeset(%Project{}, %{})

      assert %{
               name: ["can't be blank"],
               org_id: ["can't be blank"],
               creator_id: ["can't be blank"]
             } == errors_on(changeset)
    end

    test "returns error when duplicate project name is used", context do
      %{creator: creator} = context
      project = insert(:project)

      params = %{
        org_id: project.org_id,
        name: project.name,
        creator_id: creator.id
      }

      changeset = Project.changeset(%Project{}, params)

      {:error, changeset} = Repo.insert(changeset)

      assert %{name: ["unique name under organisation"]} == errors_on(changeset)
    end

    test "returns error when organisation is not valid", context do
      %{creator: creator} = context
      project = insert(:project)

      params = %{
        org_id: -1,
        name: project.name,
        creator_id: creator.id
      }

      changeset = Project.changeset(%Project{}, params)

      {:error, changeset} = Repo.insert(changeset)

      assert %{org: ["does not exist"]} == errors_on(changeset)
    end

    test "returns a valid changeset", context do
      %{org: org, creator: creator} = context

      params = %{
        org_id: org.id,
        name: "Demo Project",
        creator_id: creator.id
      }

      %{valid?: validity} = Project.changeset(%Project{}, params)
      assert validity
    end
  end

  describe "update_changeset/2" do
    setup do
      project = insert(:project)

      [project: project]
    end

    test "updates project", context do
      %{project: project} = context

      params = %{
        name: "Demo Project updated"
      }

      %{valid?: validity} = Project.update_changeset(project, params)
      assert validity
    end
  end
end
