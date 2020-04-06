defmodule AcqdatCore.Schema.Asset do
  @moduledoc """
  Models an Asset in the system.

  A Asset can be any entity in an organisation which will interact with our sensor
  and send data to and forth in our given platform. An `asset` help creates a
  hierarchy for an organization.

  In order to deal with hierarchical structure of the assets,  we make use
  of [`as_nested_set`](http://mikehillyer.com/articles/managing-hierarchical-data-in-mysql/).
  The data structure used improves query response time for extracting hierarchical
  data.

  As_nested_set has a drawback though that during writes the entire tree is
  readjusted. In order to limit the effects of readjustment we scope the
  tree with `organisation_id`. This keeps the scope of adjustments limited
  to a specific organisation.
  """
  use AcqdatCore.Schema

  alias AcqdatCore.Schema.Organisation

  use AsNestedSet, scope: [:org_id]

  @typedoc """
  `uuid`: A universally unique id to identify the Asset.
  `name`: Name for easy identification of the Asset.
  `access_token`: Access token to be used while sending data
              to server from the Asset.
  `parent_id`: Id of parent asset, if it's empty the asset is a root.
  `lft`: left index for tree structure.
  `rgt`: right index for tree structure.
  `mapped_parameters`: The parameters for an asset. They are mapped to parameter
    of a sensor belonging to the asset, hence the name.
  """
  @type t :: %__MODULE__{}

  schema("acqdat_asset") do
    field(:uuid, :string, null: false)
    field(:slug, :string, null: false)
    field(:name, :string)
    field(:parent_id, :integer)
    field(:lft, :integer)
    field(:rgt, :integer)
    field(:metadata, :map)
    field(:description, :string)

    embeds_many :mapped_parameters, MappedParameters do
      field(:name, :string, null: false)
      field(:uuid, :string, null: false)
      field(:sensor_uuid, :string, null: false)
      field(:parameter_uuid, :string, null: false)
    end

    field(:image_url, :string)
    field(:image, :any, virtual: true)

    belongs_to(:org, Organisation, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(uuid slug parent_id org_id)a
  @optional_params ~w(name lft rgt metadata description)a

  @required_embedded_params ~w(name uuid parameter_uuid sensor_uuid)a
  @permitted @required_params ++ @optional_params

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = asset, params) do
    asset
    |> cast(params, @permitted)
    |> cast_embed(:mapped_parameters, with: &mapped_parameters_changeset/2)
    |> add_uuid()
    |> add_slug()
    |> validate_required(@required_params)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = asset, params) do
    asset
    |> cast(params, @permitted)
    |> cast_embed(:mapped_parameters, with: &mapped_parameters_changeset/2)
    |> validate_required(@required_params)
    |> common_changeset()
  end

  def common_changeset(changeset) do
    changeset
    |> assoc_constraint(:org)
    |> unique_constraint(:slug, name: :acqdat_gateway_slug_index)
    |> unique_constraint(:uuid, name: :acqdat_gateway_uuid_index)
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

  defp mapped_parameters_changeset(schema, params) do
    schema
    |> cast(params, @required_embedded_params)
    |> add_uuid()
    |> validate_required(@required_embedded_params)
  end
end