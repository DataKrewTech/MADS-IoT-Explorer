defmodule AcqdatCore.Schema.AssetType do
  @moduledoc """
  Models a asset-type in the system.

  A asset-type is responsible for deciding the parameters of a asset of an organisation.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.{Organisation}

  @typedoc """
  `name`: A unique name for asset per device. Note the same
          name can be used for asset associated with another
          device.
   `description`: A description of the asset-type
   `metadata`: A metadata field which will store all the data related to asset-type
   `org_id`: A organisation to which the asset and corresponding asset-type is belonged to.
  `parameters`: The different parameters of the asset.
  """
  @type t :: %__MODULE__{}

  schema("acqdat_asset_types") do
    field(:uuid, :string, null: false)
    field(:slug, :string, null: false)
    field(:name, :string, null: false)
    field(:description, :string)
    field(:sensor_type_present, :boolean, default: false)
    field(:sensor_type_uuid, :string)

    embeds_many :metadata, Metadata, on_replace: :delete do
      field(:name, :string, null: false)
      field(:data_type, :string, null: false)
      field(:uuid, :string, null: false)
      field(:unit, :string)
    end

    embeds_many :parameters, Parameters, on_replace: :delete do
      field(:name, :string, null: false)
      field(:uuid, :string, null: false)
      field(:data_type, :string, null: false)
      field(:unit, :string)
    end

    # associations
    belongs_to(:org, Organisation, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(uuid slug org_id name)a
  @optional_params ~w(description sensor_type_present sensor_type_uuid)a
  @embedded_metadata_required ~w(name uuid data_type)a
  @embedded_metadata_optional ~w(unit)a
  @permitted_metadata @embedded_metadata_optional ++ @embedded_metadata_required
  @embedded_required_params ~w(name uuid data_type)a
  @embedded_optional_params ~w(unit)a
  @permitted_embedded @embedded_optional_params ++ @embedded_required_params

  @permitted @required_params ++ @optional_params

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = asset_type, params) do
    asset_type
    |> cast(params, @permitted)
    |> cast_embed(:parameters, with: &parameters_changeset/2)
    |> cast_embed(:metadata, with: &metadata_changeset/2)
    |> add_uuid()
    |> add_slug()
    |> validate_required(@required_params)
    |> common_changeset()
  end

  @spec update_changeset(
          AcqdatCore.Schema.AssetType.t(),
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = asset_type, params) do
    asset_type
    |> cast(params, @permitted)
    |> cast_embed(:parameters, with: &parameters_changeset/2)
    |> validate_required(@required_params)
    |> common_changeset()
  end

  @spec common_changeset(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def common_changeset(changeset) do
    changeset
    |> assoc_constraint(:org)
    |> unique_constraint(:slug, name: :acqdat_asset_types_slug_index)
    |> unique_constraint(:uuid, name: :acqdat_asset_types_uuid_index)
    |> unique_constraint(:name,
      name: :acqdat_asset_types_name_org_id_index,
      message: "asset type already exists"
    )
  end

  defp add_uuid(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> put_change(:uuid, UUID.uuid1(:hex))
  end

  defp add_slug(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> put_change(:slug, Slugger.slugify(random_string(12)))
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end

  defp parameters_changeset(schema, params) do
    schema
    |> cast(params, @permitted_embedded)
    |> add_uuid()
    |> validate_required(@embedded_required_params)
  end

  defp metadata_changeset(schema, params) do
    schema
    |> cast(params, @permitted_metadata)
    |> add_uuid()
    |> validate_required(@embedded_metadata_required)
  end
end
