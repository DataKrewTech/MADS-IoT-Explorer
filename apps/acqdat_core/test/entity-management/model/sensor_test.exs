defmodule AcqdatCore.Model.EntityManagement.SensorTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  alias AcqdatCore.Model.EntityManagement.Sensor, as: SensorModel

  describe "get_by_id/1" do
    test "returns a particular sensor" do
      sensor = insert(:sensor)

      {:ok, result} = SensorModel.get(sensor.id)
      assert not is_nil(result)
      assert result.id == sensor.id
    end

    test "returns error not found, if sensor is not present" do
      {:error, result} = SensorModel.get(-1)
      assert result == "not found"
    end
  end

  describe "create/1" do
    setup do
      org = insert(:organisation)
      project = insert(:project)

      [org: org, project: project]
    end

    test "creates a sensor with supplied params", context do
      %{org: org, project: project} = context

      params = %{
        org_id: org.id,
        name: "Demo Project",
        project_id: project.id
      }

      assert {:ok, _sensor} = SensorModel.create(params)
    end

    test "fails if org_id is not present", context do
      %{project: project} = context

      params = %{
        name: "Demo sensor",
        project_id: project.id
      }

      assert {:error, changeset} = SensorModel.create(params)
      assert %{org_id: ["can't be blank"]} == errors_on(changeset)
    end

    test "fails if name is not present", context do
      %{org: org, project: project} = context

      params = %{
        org_id: org.id,
        project_id: project.id
      }

      assert {:error, changeset} = SensorModel.create(params)
      assert %{name: ["can't be blank"]} == errors_on(changeset)
    end

    test "fails if project is not present", context do
      %{org: org} = context

      params = %{
        org_id: org.id,
        name: "Demo sensor Test"
      }

      assert {:error, changeset} = SensorModel.create(params)
      assert %{project_id: ["can't be blank"]} == errors_on(changeset)
    end
  end

  describe "update/2" do
    setup do
      project = insert(:project)
      sensor = insert(:sensor)

      [sensor: sensor, project: project]
    end

    test "updates the sensor's name", context do
      %{sensor: sensor} = context

      params = %{
        name: "updated sensor name"
      }

      assert {:ok, sensor} = SensorModel.update(sensor, params)
      assert sensor.name == "updated sensor name"
    end

    test "updates the sensor's parent as project", context do
      %{sensor: sensor, project: project} = context

      params = %{
        parent_id: project.id,
        parent_type: "Project"
      }

      assert {:ok, sensor} = SensorModel.update(sensor, params)
      assert sensor.parent_id == project.id
      assert sensor.parent_type == "Project"
    end
  end

  describe "delete/2" do
    setup do
      sensor = insert(:sensor)

      [sensor: sensor]
    end

    test "deletes sensor", context do
      %{sensor: sensor} = context

      assert {:ok, sensor} = SensorModel.delete(sensor.id)
    end
  end
end
