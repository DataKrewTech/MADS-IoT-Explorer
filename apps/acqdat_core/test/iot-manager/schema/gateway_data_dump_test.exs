defmodule AcqdatCore.Schema.IotManager.GatewayDataDumpTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Schema.IotManager.GatewayDataDump

  describe "changeset/2 " do
    setup do
      org = insert(:organisation)
      project = insert(:project, org: org)
      gateway = insert(:gateway, project: project, org: org)
      [gateway: gateway, org: org, project: project]
    end

    test "returns invalid if params empty" do
      params = %{}
      changeset = GatewayDataDump.changeset(%GatewayDataDump{}, params)

      assert %{
               data: ["can't be blank"],
               gateway_uuid: ["can't be blank"],
               inserted_timestamp: ["can't be blank"],
               org_uuid: ["can't be blank"],
               project_uuid: ["can't be blank"]
             } == errors_on(changeset)
    end

    test "returns invalid if gateway, project, or org uuids invalid", context do
      %{gateway: gateway, org: org, project: project} = context
      time = DateTime.utc_now() |> DateTime.to_unix()

      params = %{
        data: %{"x_axis" => 20},
        gateway_uuid: "ac",
        project_uuid: project.uuid,
        org_uuid: org.uuid,
        inserted_timestamp: time
      }

      changeset = GatewayDataDump.changeset(%GatewayDataDump{}, params)
      {:error, changeset} = Repo.insert(changeset)
      assert %{gateway: ["does not exist"]} == errors_on(changeset)

      params =
        params
        |> Map.put(:gateway_uuid, gateway.uuid)
        |> Map.put(:project_uuid, "ac")

      changeset = GatewayDataDump.changeset(%GatewayDataDump{}, params)
      {:error, changeset} = Repo.insert(changeset)
      assert %{project: ["does not exist"]} == errors_on(changeset)

      params =
        params
        |> Map.put(:project_uuid, project.uuid)
        |> Map.put(:org_uuid, "ac")

      changeset = GatewayDataDump.changeset(%GatewayDataDump{}, params)
      {:error, changeset} = Repo.insert(changeset)
      assert %{org: ["does not exist"]} == errors_on(changeset)
    end
  end
end
