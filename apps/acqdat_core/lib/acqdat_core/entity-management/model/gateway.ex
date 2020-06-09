defmodule AcqdatCore.Model.EntityManagement.Gateway do
  import Ecto.Query
  alias AcqdatCore.Schema.EntityManagement.Gateway
  alias AcqdatCore.Schema.EntityManagement.Project
  alias AcqdatCore.Model.Helper, as: ModelHelper
  alias AcqdatCore.Repo

  def create(params) do
    changeset = Gateway.changeset(%Gateway{}, params)
    Repo.insert(changeset)
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
    changeset = Gateway.update_changeset(project, params)

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
end
