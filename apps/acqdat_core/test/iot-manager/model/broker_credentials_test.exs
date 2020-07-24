defmodule AcqdatCore.Model.IotManager.BrokerCredentialsTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  alias AcqdatCore.Schema.IotManager.BrokerCredentials
  alias AcqdatCore.Model.IotManager.MQTT.BrokerCredentials, as: BrokerModel
  import AcqdatCore.Support.Factory

  describe "broker_clients" do
    test "returns all project clients with credentials setup" do
      setup_clients()
      result = BrokerModel.broker_clients()
      assert length(result) == 2
      assert Enum.all?(result, fn x -> x.entity_type == "Project" end)
    end
  end

  def setup_clients() do
    gateway = insert(:gateway) |> create_broker_credentials("Gateway")
    subscriptions = [%{topic: "/abc/xyz", qos: 0}]
    project1 = insert(:project) |> create_broker_credentials("Project", subscriptions)
    project2 = insert(:project) |> create_broker_credentials("Project", subscriptions)

    Repo.insert_all(BrokerCredentials, [gateway, project1, project2])
  end

  def create_broker_credentials(entity, type, subscriptions \\ []) do
    access_token = "abce123"
    time = DateTime.utc_now() |> DateTime.truncate(:second)
    %{
      entity_uuid: entity.uuid, entity_type: type, access_token: access_token,
      subscriptions: subscriptions, inserted_at: time,
      updated_at: time
    }
  end

end
