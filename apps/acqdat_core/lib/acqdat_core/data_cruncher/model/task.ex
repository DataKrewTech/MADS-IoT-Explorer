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
end
