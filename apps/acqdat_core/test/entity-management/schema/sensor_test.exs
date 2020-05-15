defmodule AcqdatCore.Schema.EntityManagement.SensorTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory

  alias AcqdatCore.Schema.EntityManagement.Sensor

  describe "changeset/2" do
    setup do
      organisation = insert(:organisation)
      sensor_type = insert(:sensor_type)
      project = insert(:project)
      [organisation: organisation, project: project, sensor_type: sensor_type]
    end

    test "returns a valid changeset", context do
      %{organisation: organisation, project: project, sensor_type: sensor_type} = context

      params = %{
        uuid: UUID.uuid1(:hex),
        name: "Temperature",
        org_id: organisation.id,
        project_id: project.id,
        sensor_type_id: sensor_type.id
      }

      %{valid?: validity} = Sensor.changeset(%Sensor{}, params)
      assert validity
    end

    test "returns invalid if params empty" do
      %{valid?: validity} = changeset = Sensor.changeset(%Sensor{}, %{})
      refute validity

      assert %{
               org_id: ["can't be blank"],
               name: ["can't be blank"],
               project_id: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "returns error if organisation assoc constraint not satisfied", %{project: project} do
      params = %{
        uuid: UUID.uuid1(:hex),
        name: "Temperature",
        org_id: -1,
        project_id: project.id,
        sensor_type_id: 1
      }

      changeset = Sensor.changeset(%Sensor{}, params)

      {:error, result_changeset} = Repo.insert(changeset)
      assert %{org: ["does not exist"]} == errors_on(result_changeset)
    end

    test "returns error if project assoc constraint not satisfied", %{organisation: organisation} do
      params = %{
        uuid: UUID.uuid1(:hex),
        name: "Temperature",
        org_id: organisation.id
      }

      changeset = Sensor.changeset(%Sensor{}, params)

      {:error, result_changeset} = Repo.insert(changeset)

      assert %{project_id: ["can't be blank"], sensor_type_id: ["can't be blank"]} ==
               errors_on(result_changeset)
    end

    test "returns error if unique constraint not satisified", %{project: project} do
      params = %{
        uuid: UUID.uuid1(:hex),
        name: "Temperature",
        org_id: 1,
        project_id: project.id,
        sensor_type_id: 1
      }

      changeset = Sensor.changeset(%Sensor{}, params)

      Repo.insert(changeset)

      params = %{
        uuid: UUID.uuid1(:hex),
        name: "Viscosity",
        org_id: 1,
        project_id: project.id,
        sensor_type_id: 1
      }

      new_changeset = Sensor.changeset(%Sensor{}, params)
      {:error, result_changeset} = Repo.insert(new_changeset)
      assert %{org: ["does not exist"]} == errors_on(result_changeset)
    end
  end
end
