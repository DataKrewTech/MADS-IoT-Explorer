defmodule AcqdatCore.Schema.EntityManagement.GatewayDataTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  alias AcqdatCore.Schema.EntityManagement.GatewayData

  describe "changeset/2" do
    setup do
      gateway = insert(:gateway)
      organisation = insert(:organisation)

      [gateway: gateway, organisation: organisation]
    end

    test "returns a valid changeset and makes insert", context do
      %{gateway: gateway, organisation: organisation} = context

      params = %{
        parameters: %{data_type: "string", name: "Voltage", value: "456"},
        inserted_timestamp: DateTime.utc_now(),
        gateway_id: gateway.id,
        org_id: organisation.id
      }

      %{valid?: validity} = changeset = GatewayData.changeset(%GatewayData{}, params)
      assert validity

      assert {:ok, data} = Repo.insert(changeset)
    end

    test "fails if inserted_timestamp is not present", context do
      %{gateway: gateway} = context

      params = %{
        parameters: %{data_type: "string", name: "Voltage", value: "456"},
        gateway_id: gateway.id,
        org_id: gateway.org_id
      }

      %{valid?: validity} = changeset = GatewayData.changeset(%GatewayData{}, params)
      refute validity

      assert %{inserted_timestamp: ["can't be blank"]} = errors_on(changeset)
    end

    test "fails if organisation not present", context do
      %{gateway: gateway} = context

      params = %{
        parameters: %{data_type: "string", name: "Voltage", value: "456"},
        inserted_timestamp: DateTime.utc_now(),
        gateway_id: gateway.id
      }

      %{valid?: validity} = changeset = GatewayData.changeset(%GatewayData{}, params)
      refute validity

      assert %{org_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "fails if gateway not present", context do
      %{gateway: gateway} = context

      params = %{
        parameters: %{data_type: "string", name: "Voltage", value: "456"},
        inserted_timestamp: DateTime.utc_now(),
        org_id: gateway.org_id
      }

      %{valid?: validity} = changeset = GatewayData.changeset(%GatewayData{}, params)
      refute validity

      assert %{gateway_id: ["can't be blank"]} = errors_on(changeset)
    end
  end
end
