defmodule AcqdatCore.DataCrunche.Model.Task do
  import Ecto.Query
  alias AcqdatCore.Repo
  alias AcqdatCore.DataCruncher.Schema.Tasks
  alias AcqdatCore.Model.Helper, as: ModelHelper

  def create(params) do
    changeset = Tasks.changeset(%Tasks{}, params)
    Repo.insert(changeset)
  end
end
