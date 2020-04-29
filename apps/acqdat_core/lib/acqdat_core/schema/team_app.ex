defmodule AcqdatCore.Schema.TeamApp do
  @moduledoc """
  Models a third table between Team and App, to keep all the associations between team and app
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.{Team, App}

  @type t :: %__MODULE__{}

  schema "teams_apps" do
    # associations
    belongs_to(:team, Team)
    belongs_to(:app, App)
  end

  @required_params ~w(team_id app_id)a

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = team_app, params) do
    common_changeset(team_app, params)
  end

  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = team_app, params) do
    common_changeset(team_app, params)
  end

  defp common_changeset(team_app, params) do
    team_app
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> foreign_key_constraint(:team_id)
    |> foreign_key_constraint(:app_id)
    |> unique_constraint(:team_id,
      name: :team_id_app_id_unique_index,
      message: "team_id_app_id is not unique"
    )
  end
end
