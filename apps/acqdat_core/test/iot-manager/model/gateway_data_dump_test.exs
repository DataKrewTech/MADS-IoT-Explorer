defmodule AcqdatCore.Model.IotManager.GatewayDataDumpTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.IotManager.GatewayDataDump
  alias AcqdatCore.Schema.IoTManager.GatewayError

  describe "create/1 " do
    setup do
      org = insert(:organisation)
      project = insert(:project, org: org)

      data = %{
        "axis_object" => %{
          "x_axis" => 20,
          "z_axis" => [22, 23],
          "lambda" => %{"alpha" => 24, "beta" => 25}
        },
        "y_axis" => 21,
        "project_id" => 1,
        "xyz" => %{},
        "timestamp" => 1_596_115_581
      }

      [org: org, project: project, dump_data: data]
    end

    test "create when timestamp mapping set for gateway", context do
      %{org: org, project: project, dump_data: data_dump} = context
      gateway = insert(:gateway, org: org, project: project, timestamp_mapping: "timestamp")

      params = %{
        org_uuid: org.uuid,
        project_uuid: project.uuid,
        gateway_uuid: gateway.uuid,
        data: data_dump
      }

      assert {:ok, result} = GatewayDataDump.create(params)
      assert result.inserted_timestamp == data_dump["timestamp"]
    end

    test "create when timestamp mapping not set", context do
      %{org: org, project: project, dump_data: data_dump} = context
      gateway = insert(:gateway, org: org, project: project)

      params = %{
        org_uuid: org.uuid,
        project_uuid: project.uuid,
        gateway_uuid: gateway.uuid,
        data: data_dump
      }

      assert {:ok, result} = GatewayDataDump.create(params)
    end

    test "error when gateway uuid invalid", context do
      %{org: org, project: project, dump_data: data_dump} = context

      params = %{
        org_uuid: org.uuid,
        project_uuid: project.uuid,
        gateway_uuid: "ab",
        data: data_dump
      }

      {:error, result} = GatewayDataDump.create(params)
      assert result == "Gateway not found"
    end

    test "error when data with same timestamp inserted", context do
      %{org: org, project: project, dump_data: data_dump} = context
      gateway = insert(:gateway, org: org, project: project, timestamp_mapping: "timestamp")

      params = %{
        org_uuid: org.uuid,
        project_uuid: project.uuid,
        gateway_uuid: gateway.uuid,
        data: data_dump
      }

      assert {:ok, result} = GatewayDataDump.create(params)
      ## insert the data with same timestamp again
      assert {:error, changeset} = GatewayDataDump.create(params)

      assert %{
               inserted_timestamp: ["duplicate data with same timestamp inserted"]
             } == errors_on(changeset)
    end
  end

  describe "delete_errors/1 " do
    setup do
      org = insert(:organisation)
      project = insert(:project, org: org)
      gateway = insert(:gateway, org: org, project: project, timestamp_mapping: "timestamp")

      ## insert errors older than a 7 days
      time_now = DateTime.truncate(Timex.now(), :second)
      errors = build_error_record(5, gateway.uuid, Timex.shift(time_now, days: -8))
      {errors, _} = Repo.insert_all(GatewayError, errors)
      [errors: errors, gateway: gateway]
    end

    test "deletes errors 7 days from current provided date", context do
      %{errors: errors, gateway: gateway} = context

      time_now = DateTime.truncate(Timex.now(), :second)

      ## insert some more errors but keep them at 3 days
      new_errors = build_error_record(3, gateway.uuid, Timex.shift(time_now, days: -3))
      Repo.insert_all(GatewayError, new_errors)

      {deleted, _} = GatewayDataDump.delete_errors(time_now)
      assert deleted == errors
    end
  end

  defp build_error_record(number, gateway_uuid, timestamp) do
    Enum.map(0..(number - 1), fn _ ->
      %{
        data: %{key1: 1, key2: 2},
        error: %{inserted_timestamp: "invalid time"},
        gateway_uuid: gateway_uuid,
        inserted_at: timestamp
      }
    end)
  end
end
