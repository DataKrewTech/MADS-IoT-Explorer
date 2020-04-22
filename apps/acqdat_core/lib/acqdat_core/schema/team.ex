defmodule AcqdatCore.Schema.Team do
  @moduledoc """
  Models a team in acqdat.
  Here team specifies group of user, who share common resources like assets and apps
  """

  use AcqdatCore.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias AcqdatCore.Schema.{Asset, App, User, Organisation}
  alias AcqdatCore.Repo

  @type t :: %__MODULE__{}

  schema("acqdat_teams") do
    field(:name, :string, null: false)
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
  @optional ~w(team_lead_id enable_tracking)a
  @permitted @optional ++ @required

  def changeset(%__MODULE__{} = team, params) do
    team
    |> cast(params, @permitted)
    |> validate_required(@required)
    |> unique_constraint(:name)
    |> assoc_constraint(:org)
    |> assoc_constraint(:creator)
    |> associate_users_changeset(params[:users] || [])
    |> associate_assets_changeset(params[:assets] || [])
    |> associate_apps_changeset(params[:apps] || [])
  end

  defp associate_users_changeset(team, user_ids) do
    users = Repo.all(from(user in User, where: user.id in ^user_ids))

    put_assoc(team, :users, Enum.map(users, &change/1))
  end

  defp associate_assets_changeset(team, asset_ids) do
    assets = Repo.all(from(asset in Asset, where: asset.id in ^asset_ids))

    put_assoc(team, :assets, Enum.map(assets, &change/1))
  end

  defp associate_apps_changeset(team, app_ids) do
    apps = Repo.all(from(app in App, where: app.id in ^app_ids))

    put_assoc(team, :apps, Enum.map(apps, &change/1))
  end
end
