defmodule AcqdatCore.Schema.EntityManagement.SensorDataTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  alias AcqdatCore.Schema.EntityManagement.SensorsData

  describe "changeset/2" do
    setup do
      sensor = insert(:sensor)

      [sensor: sensor]
    end

    test "returns a valid changeset and makes insert", context do
      %{sensor: sensor} = context

      params = %{
        parameters: [
          %{
            data_type: "string",
            name: "Voltage",
            value: "456",
            uuid: "ee65c502c66811eabca598460aa1c6de"
          }
        ],
        inserted_timestamp: DateTime.utc_now(),
        sensor_id: sensor.id,
        project_id: sensor.project.id,
        org_id: sensor.org_id
      }

      %{valid?: validity} = changeset = SensorsData.changeset(%SensorsData{}, params)
      assert validity

      assert {:ok, data} = Repo.insert(changeset)
    end

    test "fails if inserted_timestamp is not present", context do
      %{sensor: sensor} = context

      params = %{
        parameters: [%{data_type: "string", name: "Voltage", value: "456"}],
        sensor_id: sensor.id,
        project_id: sensor.project.id,
        org_id: sensor.org_id
      }

      %{valid?: validity} = changeset = SensorsData.changeset(%SensorsData{}, params)
      refute validity

      assert %{inserted_timestamp: ["can't be blank"]} = errors_on(changeset)
    end

    test "fails if organisation not present", context do
      %{sensor: sensor} = context

      params = %{
        parameters: [%{data_type: "string", name: "Voltage", value: "456"}],
        inserted_timestamp: DateTime.utc_now(),
        sensor_id: sensor.id,
        project_id: sensor.project.id
      }

      %{valid?: validity} = changeset = SensorsData.changeset(%SensorsData{}, params)
      refute validity

      assert %{org_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "fails if sensor not present", context do
      %{sensor: sensor} = context

      params = %{
        parameters: [%{data_type: "string", name: "Voltage", value: "456"}],
        inserted_timestamp: DateTime.utc_now(),
        org_id: sensor.org_id,
        project_id: sensor.project.id
      }

      %{valid?: validity} = changeset = SensorsData.changeset(%SensorsData{}, params)
      refute validity

      assert %{sensor_id: ["can't be blank"]} = errors_on(changeset)
    end
  end
end
