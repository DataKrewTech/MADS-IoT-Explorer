defmodule AcqdatCore.Schema.AssetCategory do
  @moduledoc """
  Models an AssetCategory

  Asset Categories are used for grouping assets together.
  E.g. if a truck is an asset in tracking company then we can
  create multiple assets for different trucks and group them
  under the category _truck_.
  An asset category has unique name per organisation.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.Organisation

  @type t :: %__MODULE__{}

  schema("acqdat_asset_categories") do
    field(:name, :string, null: false)
    field(:metadata, :map)
    field(:description, :string)
    field(:uuid, :string)

    # associations
    belongs_to(:organisation, Organisation)

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(name organisation_id)a
  @optional_params ~w(description metadata)a
  @permitted @optional_params ++ @required_params

  def changeset(%__MODULE__{} = asset_category, params) do
    asset_category
    |> cast(params, @permitted)
    |> validate_required(@required_params)
    |> add_uuid()
    |> unique_constraint(:name,
      name: :acqdat_asset_categories_name_organisation_id_index,
      message: "unique name per organisation"
    )
  end

  defp add_uuid(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> put_change(:uuid, UUID.uuid1(:hex))
  end

  defp add_uuid(changeset), do: changeset
end
