defmodule AcqdatCore.Model.IotManager.MQTT.BrokerCredentials do
  import Ecto.Query
  alias AcqdatCore.Schema.IotManager.BrokerCredentials
  alias AcqdatCore.Repo

  def broker_clients() do
    query =
      from(
        data in BrokerCredentials,
        where: data.entity_type == "Project",
        select: data
      )

    run_and_parse(query)
  end

  defp run_and_parse(query) do
    clients = Repo.all(query)

    Enum.map(
      clients,
      fn client ->
        subscriptions = format_subscriptions(client.subscriptions)

        client
        |> Map.from_struct()
        |> Map.put(:subscriptions, subscriptions)
      end
    )
  end

  defp format_subscriptions(subscriptions) do
    Enum.map(subscriptions, fn data ->
      {data["topic"], data["qos"]}
    end)
  end

  def subscription_present?(project_uuid) do
    query =
      from(
        data in BrokerCredentials,
        where: data.entity_uuid == ^project_uuid and data.entity_type == "Project"
      )

    Repo.exists?(query)
  end

  def create(gateway, access_token, entity_type = "Gateway") do
    params = %{entity_uuid: gateway.uuid, entity_type: entity_type, access_token: access_token}
    changeset = BrokerCredentials.changeset(%BrokerCredentials{}, params)
    Repo.insert(changeset)
  end

  def create(project, access_token, entity_type = "Project") do
    topics = [
      %{
        topic: "/org/#{project.org.uuid}/project/#{project.uuid}/gateway/+",
        qos: 0
      }
    ]

    params = %{
      entity_uuid: project.uuid,
      access_token: access_token,
      entity_type: entity_type,
      subscriptions: topics
    }

    changeset = BrokerCredentials.changeset(%BrokerCredentials{}, params)
    Repo.insert(changeset)
  end

  def delete(entity_uuid) do
    entity = Repo.get_by(BrokerCredentials, entity_uuid: entity_uuid)
    Repo.delete(entity)
  end
end
