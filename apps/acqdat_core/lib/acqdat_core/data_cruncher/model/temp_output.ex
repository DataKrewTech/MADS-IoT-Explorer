defmodule AcqdatCore.DataCruncher.Model.TempOutput do
  import Ecto.Query
  alias AcqdatCore.Repo
  alias AcqdatCore.DataCruncher.Schema.TempOutput
  alias AcqdatCore.Model.Helper, as: ModelHelper

  def create(params) do
    changeset = TempOutput.changeset(%TempOutput{}, params)
    Repo.insert(changeset)
  end
end
