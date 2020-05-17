defmodule AcqdatCore.Model.RoleManagement.Team do
  @moduledoc """
  Exposes APIs for handling Team related fields.
  """

  alias AcqdatCore.Schema.RoleManagement.{User, App, Team}
  alias AcqdatCore.Schema.EntityManagement.Asset
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.Helper, as: ModelHelper
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

  def update(team, params) do
    changeset = Team.update_changeset(team, params)
    Repo.update(changeset)
  end

  def update_assets(team, asset_ids) do
    assets =
      Asset
      |> where([asset], asset.id in ^asset_ids)
      |> Repo.all()

    changeset = Team.update_assets(team, assets)
    Repo.update(changeset)
  end

  def update_apps(team, app_ids) do
    assets =
      App
      |> where([app], app.id in ^app_ids)
      |> Repo.all()

    changeset = Team.update_apps(team, assets)
    Repo.update(changeset)
  end

  def update_members(team, member_ids) do
    members =
      User
      |> where([member], member.id in ^member_ids)
      |> Repo.all()

    changeset = Team.update_members(team, members)
    Repo.update(changeset)
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

  def get_all(%{page_size: page_size, page_number: page_number, org_id: org_id}) do
    paginated_team_data =
      Team
      |> where([team], team.org_id == ^org_id)
      |> order_by(:name)
      |> Repo.paginate(page: page_number, page_size: page_size)

    team_data_with_preloads =
      paginated_team_data.entries |> Repo.preload([:users, :assets, :apps])

    ModelHelper.paginated_response(team_data_with_preloads, paginated_team_data)
  end
end
