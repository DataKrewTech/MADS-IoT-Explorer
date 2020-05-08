defmodule AcqdatCore.Schema.RoleManagement.TeamAsset do
  @moduledoc """
  Models a third table between Team and Asset, to keep all the associations between team and asset
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.RoleManagement.Team
  alias AcqdatCore.Schema.Asset

  @type t :: %__MODULE__{}

  schema "teams_assets" do
    # associations
    belongs_to(:team, Team)
    belongs_to(:asset, Asset)
  end

  @required_params ~w(team_id asset_id)a

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = team_asset, params) do
    common_changeset(team_asset, params)
  end

  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = team_asset, params) do
    common_changeset(team_asset, params)
  end

  defp common_changeset(team_asset, params) do
    team_asset
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> foreign_key_constraint(:team_id)
    |> foreign_key_constraint(:asset_id)
    |> unique_constraint(:team_id,
      name: :asset_id_team_id_unique_index,
      message: "team_id_asset_id is not unique"
    )
  end
end
