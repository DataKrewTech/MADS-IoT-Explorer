defmodule AcqdatCore.DataCruncher.Model.TempOutput do
  alias AcqdatCore.Repo
  alias AcqdatCore.DataCruncher.Schema.TempOutput

  def create(params) do
    changeset = TempOutput.changeset(%TempOutput{}, params)
    Repo.insert(changeset)
  end

  def update(output, params) do
    changeset = TempOutput.changeset(output, params)
    Repo.update(changeset)
  end

  # def create_or_update(params) do
  #   case Repo.get(TempOutput, id) do
  #     nil  -> %Post{id: id} # Post not found, we build one
  #     post -> post          # Post exists, let's use it
  #   end
  #   |> Post.changeset(changes)
  #   |> MyRepo.insert_or_update
  # end
end
