defmodule AcqdatCore.Model.Team do
  @moduledoc """
  Exposes APIs for handling Team related fields.
  """

  alias AcqdatCore.Schema.{User, Asset, App, Team}
  alias AcqdatCore.Repo
  import Ecto.Query

  @doc """
  Creates a Team with the supplied params.

  Expects following keys.
  - `name`
  - `org_id`
  """
  @spec create(map) :: {:ok, Team.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    changeset = Team.changeset(%Team{}, params)
    Repo.insert(changeset)
  end

  def get(id) when is_integer(id) do
    case Repo.get(Team, id) do
      nil ->
        {:error, "not found"}

      team ->
        {:ok, team}
    end
  end

  def get_all() do
    Repo.all(Team)
  end

  def get_all(%{page_size: page_size, page_number: page_number}) do
    Team |> order_by(:name) |> Repo.paginate(page: page_number, page_size: page_size)
  end
end
