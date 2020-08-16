defmodule AcqdatCore.DataCrunche.Model.Task do
  import Ecto.Query
  alias AcqdatCore.Repo
  alias AcqdatCore.DataCruncher.Schema.Tasks
  alias AcqdatCore.Model.Helper, as: ModelHelper

  def create(params) do
    changeset = Tasks.changeset(%Tasks{}, params)
    Repo.insert(changeset)
  end

  def get(id) when is_integer(id) do
    case Repo.get(Tasks, id) |> Repo.preload([:workflows]) do
      nil ->
        {:error, "task not found"}

      task ->
        {:ok, task}
    end
  end

  def get_all(%{page_size: page_size, page_number: page_number, org_id: org_id, user_id: user_id}) do
    query =
      from(task in Tasks,
        where: task.org_id == ^org_id and task.user_id == ^user_id,
        preload: [:user]
      )

    query |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end
end
