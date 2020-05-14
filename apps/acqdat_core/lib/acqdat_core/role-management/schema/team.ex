defmodule AcqdatCore.Schema.RoleManagement.Team do
  @moduledoc """
  Models a team in acqdat.
  Here team specifies group of user, who share common resources like assets and apps
  """

  use AcqdatCore.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias AcqdatCore.Schema.EntityManagement.{Asset, Organisation}
  alias AcqdatCore.Schema.RoleManagement.{App, User}
  alias AcqdatCore.Repo

  @type t :: %__MODULE__{}

  schema("acqdat_teams") do
    field(:name, :string, null: false)
    field(:description, :string)
    field(:enable_tracking, :boolean, default: false)

    # associations
    belongs_to(:org, Organisation, on_replace: :delete)
    belongs_to(:team_lead, User)
    belongs_to(:creator, User)
    many_to_many(:users, User, join_through: "users_teams", on_replace: :delete)
    many_to_many(:assets, Asset, join_through: "teams_assets", on_replace: :delete)
    many_to_many(:apps, App, join_through: "teams_apps", on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required ~w(name org_id creator_id)a
  @optional ~w(team_lead_id enable_tracking description)a
  @permitted @optional ++ @required

  def changeset(%__MODULE__{} = team, params) do
    team
    |> cast(params, @permitted)
    |> validate_required(@required)
    |> unique_constraint(:name)
    |> assoc_constraint(:org)
    |> assoc_constraint(:creator)
    |> assoc_constraint(:team_lead)
    |> associate_users_changeset(params[:users] || [])
    |> associate_assets_changeset(params[:assets] || [])
    |> associate_apps_changeset(params[:apps] || [])
  end

  def update_changeset(%__MODULE__{} = team, params) do
    team
    |> cast(params, @permitted)
    |> validate_required(@required)
    |> unique_constraint(:name)
    |> assoc_constraint(:org)
    |> assoc_constraint(:creator)
    |> assoc_constraint(:team_lead)
  end

  def update_assets(%__MODULE__{} = team, assets) do
    team
    |> Repo.preload(:assets)
    |> change()
    |> put_assoc(:assets, Enum.map(assets, &change/1))
  end

  def update_apps(%__MODULE__{} = team, apps) do
    team
    |> Repo.preload(:apps)
    |> change()
    |> put_assoc(:apps, Enum.map(apps, &change/1))
  end

  def update_members(%__MODULE__{} = team, members) do
    team
    |> Repo.preload(:users)
    |> change()
    |> put_assoc(:users, Enum.map(members, &change/1))
  end

  defp associate_users_changeset(team, user_ids) do
    users = Repo.all(from(user in User, where: user.id in ^user_ids))

    team
    |> put_assoc(:users, Enum.map(users, &change/1))
  end

  defp associate_assets_changeset(team, asset_ids) do
    assets = Repo.all(from(asset in Asset, where: asset.id in ^asset_ids))

    team
    |> put_assoc(:assets, Enum.map(assets, &change/1))
  end

  defp associate_apps_changeset(team, app_ids) do
    apps = Repo.all(from(app in App, where: app.id in ^app_ids))

    team
    |> put_assoc(:apps, Enum.map(apps, &change/1))
  end
end
