defmodule AcqdatCore.Schema.RoleManagement.UserTeam do
  @moduledoc """
  Models a third table between User and Team, to keep all the associations between team and user
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.RoleManagement.{Team, User}

  @type t :: %__MODULE__{}

  schema "users_teams" do
    # associations
    belongs_to(:team, Team)
    belongs_to(:user, User)
  end

  @required_params ~w(team_id user_id)a

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = user_team, params) do
    common_changeset(user_team, params)
  end

  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = user_team, params) do
    common_changeset(user_team, params)
  end

  defp common_changeset(user_team, params) do
    user_team
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> foreign_key_constraint(:team_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:team_id,
      name: :user_id_team_id_unique_index,
      message: "team_id_user_id is not unique"
    )
  end
end
