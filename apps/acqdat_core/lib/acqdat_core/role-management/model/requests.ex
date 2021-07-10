defmodule AcqdatCore.Model.RoleManagement.Requests do
  @moduledoc """
  Exposes APIs for handling requests related fields.
  """

  alias AcqdatCore.Schema.RoleManagement.Requests
  alias AcqdatCore.Repo
  import Ecto.Query

  @doc """
  Created Requests
  """
  def create(params) do
    changeset = Requests.changeset(%Requests{}, params)
    Repo.insert(changeset)
  end

  @doc """
  Updates Requests
  """
  def update(request, params) do
    changeset = Requests.changeset(request, params)
    Repo.update(changeset)
  end

  @doc """
  Returns request by the supplied id.
  """
  def get(id) when is_integer(id) do
    case Repo.get(Requests, id) do
      nil ->
        {:error, "not found"}

      request ->
        {:ok, request}
    end
  end

  @doc """
  Returns all requests.
  """
  def get_all(%{page_size: page_size, page_number: page_number}) do
    Requests
    |> order_by(desc: :inserted_at)
    |> Repo.paginate(page: page_number, page_size: page_size)
  end

  @doc """
  Deletes Requests.

  Expects `equest_id` as the argument.
  """
  def delete(id) when is_integer(id) do
    Repo.get_by(Requests, id: id) |> Repo.delete()
  end
end
