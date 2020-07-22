defmodule AcqdatCore.Model.IotManager.GatewayDataDump do
  import Ecto.Query
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.IotManager.GatewayDataDump
  alias AcqdatCore.Model.Helper, as: ModelHelper

  def create(params) do
    changeset = GatewayDataDump.changeset(%GatewayDataDump{}, params)
    Repo.insert(changeset)
  end

  def get_all(%{page_size: page_size, page_number: page_number}) do
    GatewayDataDump |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all(
        %{page_size: page_size, page_number: page_number, org_id: org_id, project_id: project_id},
        preloads
      ) do
    query =
      from(data_dump in GatewayDataDump,
        where: data_dump.project_id == ^project_id and data_dump.org_id == ^org_id
      )

    paginated_data_dump =
      query |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    data_dump_with_preloads = paginated_data_dump.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(data_dump_with_preloads, paginated_data_dump)
  end
end
