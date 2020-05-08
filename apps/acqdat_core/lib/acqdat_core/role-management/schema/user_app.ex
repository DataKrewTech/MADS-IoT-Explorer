defmodule AcqdatCore.Schema.RoleManagement.UserApp do
  @moduledoc """
  Models a third table between User and Asser, to keep all the associations between user and app
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.RoleManagement.{User, App}

  @type t :: %__MODULE__{}

  schema "app_user" do
    # associations
    belongs_to(:user, User)
    belongs_to(:app, App)
  end

  @required_params ~w(user_id app_id)a

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = user_app, params) do
    common_changeset(user_app, params)
  end

  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = user_app, params) do
    common_changeset(user_app, params)
  end

  defp common_changeset(user_app, params) do
    user_app
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:app_id)
    |> unique_constraint(:user_id, name: :user_id_app_id_unique_index)
  end
end
