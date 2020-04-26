defmodule AcqdatCore.Schema.OrgApp do
  @moduledoc """
  Models a third table between Organisation and App, to keep all the associations between organisation and app
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.{Organisation, App}

  @primary_key false
  @type t :: %__MODULE__{}

  schema "org_apps" do
    # associations
    belongs_to(:org, Organisation, primary_key: true)
    belongs_to(:app, App, primary_key: true)
  end

  @required_params ~w(org_id app_id)a

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = org_app, params) do
    common_changeset(org_app, params)
  end

  @spec update_changeset(t, map) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = org_app, params) do
    common_changeset(org_app, params)
  end

  defp common_changeset(org_app, params) do
    org_app
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> foreign_key_constraint(:org_id)
    |> foreign_key_constraint(:app_id)
    |> unique_constraint(:app_id, name: :org_apps_unique_index)
  end
end
