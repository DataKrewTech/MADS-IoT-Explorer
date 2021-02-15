defmodule AcqdatCore.Model.IotManager.GatewayDataDumpTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.IotManager.GatewayDataDump

  describe "create/1" do
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
end
