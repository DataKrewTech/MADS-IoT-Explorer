defmodule AcqdatCore.Model.IotManager.GatewayDataDump do
  import Ecto.Query
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.IotManager.GatewayDataDump
  alias AcqdatCore.Model.IotManager.Gateway
  alias AcqdatCore.Model.Helper, as: ModelHelper

  def create(params) do
    parse_params_and_insert(params)
  end

  def get_all(%{page_size: page_size, page_number: page_number}) do
    GatewayDataDump |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all(
        %{
          page_size: page_size,
          page_number: page_number,
          org_uuid: org_uuid,
          project_uuid: project_uuid,
          gateway_uuid: gateway_uuid
        },
        preloads
      ) do
    query =
      from(data_dump in GatewayDataDump,
        where:
          data_dump.project_uuid == ^project_uuid and
            data_dump.org_uuid == ^org_uuid and data_dump.gateway_uuid == ^gateway_uuid
      )

    paginated_data_dump =
      query |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    data_dump_with_preloads = paginated_data_dump.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(data_dump_with_preloads, paginated_data_dump)
  end

  defp parse_params_and_insert(params) do
    has_gateway_with_uuid(Gateway.get(%{uuid: params.gateway_uuid}), params)
  end

  defp has_gateway_with_uuid({:ok, gateway}, params) do
    inserted_timestamp = set_timestamp(gateway.timestamp_mapping, params.data)
    params = Map.put(params, :inserted_timestamp, inserted_timestamp)
    changeset = GatewayDataDump.changeset(%GatewayDataDump{}, params)
    Repo.insert(changeset)
  end

  defp has_gateway_with_uuid({:error, message}, _params) do
    {:error, message}
  end

  defp set_timestamp(nil, _data) do
    DateTime.utc_now() |> DateTime.to_unix()
  end

  defp set_timestamp(key, data) do
    data[key]
  end
end
