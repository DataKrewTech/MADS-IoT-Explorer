defmodule AcqdatCore.Schema.UserAsset do
  @moduledoc """
  Models a third table between User and Asser, to keep all the associations between user and asset
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.{User, Asset}

  @primary_key false
  @type t :: %__MODULE__{}

  schema "asset_user" do
    # associations
    belongs_to(:user, User, primary_key: true)
    belongs_to(:asset, Asset, primary_key: true)
  end

  @required_params ~w(user_id asset_id)a

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = user_asset, params) do
    common_changeset(user_asset, params)
  end

  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = user_asset, params) do
    common_changeset(user_asset, params)
  end

  defp common_changeset(user_asset, params) do
    user_asset
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:asset_id)
    |> unique_constraint(:user_id, name: :user_id_asset_id_unique_index)
  end
end
