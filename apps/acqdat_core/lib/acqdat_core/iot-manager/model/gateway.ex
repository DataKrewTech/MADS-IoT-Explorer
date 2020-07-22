defmodule AcqdatCore.Model.IotManager.Gateway do
  import Ecto.Query
  alias AcqdatCore.Schema.IotManager.Gateway
  alias AcqdatCore.Model.EntityManagement.Sensor, as: SModel
  alias AcqdatCore.Model.EntityManagement.Asset, as: AModel
  alias AcqdatCore.Model.EntityManagement.Project, as: PModel
  alias AcqdatCore.Schema.IotManager.BrokerCredentials
  alias AcqdatCore.Model.IotManager.MQTTBroker
  alias AcqdatCore.Model.Helper, as: ModelHelper
  alias AcqdatCore.Repo
  alias Ecto.Multi

  def create(params) do
    Multi.new()
    |> Multi.run(:insert_gateway, fn _, _changes ->
      changeset = Gateway.changeset(%Gateway{}, params)
      Repo.insert(changeset)
    end)
    |> Multi.run(:setup_mqtt_if_needed, fn _, changes ->
      %{insert_gateway: gateway} = changes
      start_broker_if_needed(gateway)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{insert_gateway: gateway}} ->
        {:ok, gateway}

      {:error, _failed_operation, failed_value, _} ->
        {:error, failed_value}
    end
  end

  def return_mapped_parameter(gateway_id) do
    gateway = Repo.get(Gateway, gateway_id)
    gateway.mapped_parameters
  end

  def get_by_id(id) when is_integer(id) do
    case Repo.get(Gateway, id) do
      nil ->
        {:error, "Gateway not found"}

      gateway ->
        {:ok, gateway}
    end
  end

  def update(%Gateway{} = project, params) do
    changeset = Gateway.changeset(project, params)

    case Repo.update(changeset) do
      {:ok, gateway} ->
        gateway = gateway |> Repo.preload([:org, :project])
        {:ok, gateway}

      {:error, gateway} ->
        {:error, gateway}
    end
  end

  def get_all(%{page_size: page_size, page_number: page_number}) do
    Gateway |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all(
        %{page_size: page_size, page_number: page_number, org_id: org_id, project_id: project_id},
        preloads
      ) do
    query =
      from(gateway in Gateway,
        where: gateway.project_id == ^project_id and gateway.org_id == ^org_id
      )

    paginated_project_data =
      query |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    project_data_with_preloads = paginated_project_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(project_data_with_preloads, paginated_project_data)
  end

  def delete(gateway) do
    case Repo.delete(gateway) do
      {:ok, gateway} ->
        gateway = gateway |> Repo.preload([:org, :project])
        {:ok, gateway}

      {:error, gateway} ->
        {:error, gateway}
    end
  end

  def fetch_gateways(project_id) do
    query =
      from(gateway in Gateway,
        where: gateway.parent_id == ^project_id
      )

    Repo.all(query)
  end

  def fetch_hierarchy_data(org, org_id, project_id) do
    hierarchy = PModel.hierarchy_data(org_id, project_id)
    gateway = get_gateways(project_id)
    org = Map.put_new(org, :project_data, hierarchy)
    Map.put_new(org, :gateway_data, gateway)
  end

  def attach_parent(gateway) do
    {:ok, parent} =
      case gateway.parent_type do
        "Project" -> PModel.get_by_id(gateway.parent_id)
        "Asset" -> AModel.get(gateway.parent_id)
      end

    Map.put_new(gateway, :parent, parent)
  end

  def get_gateways(project_id) do
    gateways = fetch_gateways(project_id)

    gateway_ids = fetch_gateway_ids(gateways)
    sensors = SModel.get_all_by_parent_gateway(gateway_ids)

    Enum.reduce(gateways, [], fn gateway, acc ->
      gateway =
        gateway
        |> attach_parent()
        |> attach_children(sensors)

      acc ++ [gateway]
    end)
  end

  def attach_children(gateway, sensors) do
    child_sensors = Enum.filter(sensors, fn sensor -> sensor.gateway_id == gateway.id end)

    Map.put(gateway, :childs, child_sensors)
  end

  ##################### private functions #####################

  def start_broker_if_needed(gateway) do
    initiation_for_channel(gateway, gateway.channel)
  end

  defp initiation_for_channel(gateway, "http"), do: {:ok, gateway}
  defp initiation_for_channel(gateway, "mqtt") do
    gateway = Repo.preload(gateway, :project)
    project = gateway.project
    gateway_credentials = create_broker_crdentials(gateway.uuid,
      gateway.access_token, "gateway")
    project_credentials = create_broker_crdentials(project.uuid, UUID.uuid1(:hex),
      "project")
    {2, _} = Repo.insert_all(BrokerCredentials, [gateway_credentials, project_credentials])
    start_project_client(project, project_credentials)
  end

  defp start_project_client(project, credentials) do
    topics = [
      {"/org/#{project.org.id}/project/#{project.id}/gateway/#", 0}
    ]
    MQTTBroker.start_project_client(
      project.id,
      topics,
      credentials.access_token
    )
  end

  defp create_broker_crdentials(uuid, access_token, entity_type) do
    time = DateTime.utc_now() |> DateTime.truncate(:second)
    %{
      entity_uuid: uuid,
      access_token: access_token,
      entity_type: entity_type,

      inserted_at: time,
      updated_at: time
    }
  end

  defp fetch_gateway_ids(gateways) do
    Enum.reduce(gateways, [], fn gateway, acc ->
      acc ++ [gateway.id]
    end)
  end
end
