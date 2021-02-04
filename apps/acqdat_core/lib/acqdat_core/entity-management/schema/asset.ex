defmodule AcqdatCore.Schema.EntityManagement.Asset do
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
  tree with `project_id`. This keeps the scope of adjustments limited
  to a specific project.
  """
  use AcqdatCore.Schema
  alias AcqdatCore.Schema.EntityManagement.{Organisation, Project, AssetType}
  alias AcqdatCore.Schema.RoleManagement.User
  use AsNestedSet, scope: [:project_id]

  @typedoc """
  `uuid`: A universally unique id to identify the Asset.
  `name`: Name for easy identification of the Asset.
  `description`:  Description of the asset.
  `parent_id`: Parent ID will be nil if the asset is root and will be referreing to either project or another asset whose child the current asset is.
  `lft`: left index for tree structure.
  `rgt`: right index for tree structure.
  `mapped_parameters`: The parameters for an asset. They are mapped to parameter
    of a sensor belonging to the asset, hence the name.
  `creator`: Hold the information of who has created this Asset.
  `owner`: Owner will the one which hold the right to this Asset.
  `asset type`: Every asset will have a asset type whose metadata will be mapped to asset at the time of creation.
  `metadata`: metadata will be inherited from the asset type based on the asset type id.
  """
  @type t :: %__MODULE__{}

  schema("acqdat_asset") do
    field(:uuid, :string, null: false)
    field(:slug, :string, null: false)
    field(:name, :string)
    field(:parent_id, :integer)
    field(:lft, :integer)
    field(:properties, {:array, :string})
    field(:rgt, :integer)
    field(:description, :string)

    embeds_many :metadata, Metadata, on_replace: :delete do
      field(:name, :string, null: false)
      field(:data_type, :string, null: false)
      field(:uuid, :string, null: false)
      field(:unit, :string)
      field(:value, :string)
    end

    embeds_many :mapped_parameters, MappedParameters do
      field(:name, :string, null: false)
      field(:uuid, :string, null: false)
      field(:sensor_type_uuid, :string, null: false)
      field(:sensor_uuid, :string, null: false)
      field(:parameter_uuid, :string, null: false)
    end

    field(:image_url, :string)
    field(:image, :any, virtual: true)

    # associations
    belongs_to(:org, Organisation, on_replace: :delete)
    belongs_to(:project, Project, on_replace: :delete)
    belongs_to(:creator, User)
    belongs_to(:owner, User)
    belongs_to(:asset_type, AssetType, on_replace: :delete)
    many_to_many(:users, User, join_through: "asset_user")

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(uuid slug creator_id org_id project_id asset_type_id)a
  @update_required_params ~w(uuid slug org_id )a
  @optional_params ~w(name lft rgt parent_id description properties image owner_id image_url)a

  @required_embedded_params ~w(name)a
  @optional_embedded_params ~w(name uuid parameter_uuid sensor_uuid)a

  @embedded_metadata_required ~w(name uuid data_type)a
  @embedded_metadata_optional ~w(unit)a
  @permitted_metadata @embedded_metadata_optional ++ @embedded_metadata_required

  @permitted_embedded @required_embedded_params ++ @optional_embedded_params
  @permitted @required_params ++ @optional_params

  def changeset(asset, params) do
    asset
    |> cast(params, @permitted)
    |> cast_embed(:mapped_parameters, with: &mapped_parameters_changeset/2)
    |> cast_embed(:metadata, with: &metadata_changeset/2)
    |> add_uuid()
    |> add_slug()
    |> validate_required(@required_params)
    |> common_changeset()
  end

  def update_changeset(asset, params) do
    asset
    |> cast(params, @permitted)
    |> cast_embed(:mapped_parameters, with: &mapped_parameters_changeset/2)
    |> cast_embed(:metadata, with: &metadata_changeset/2)
    |> validate_required(@update_required_params)
    |> common_changeset()
  end

  def common_changeset(changeset) do
    # TODO: there is `:acqdat_asset_slug_index` used here which seems wrong
    changeset
    |> assoc_constraint(:org)
    |> assoc_constraint(:asset_type)
    |> assoc_constraint(:project)
    |> unique_constraint(:slug, name: :acqdat_asset_slug_index)
    |> unique_constraint(:uuid, name: :acqdat_asset_uuid_index)
    |> unique_constraint(:name,
      name: :acqdat_asset_name_parent_id_org_id_index,
      message: "name already taken under this heirarchy"
    )
  end

  defp mapped_parameters_changeset(schema, params) do
    schema
    |> cast(params, @permitted_embedded)
    |> add_uuid()
    |> validate_required(@required_embedded_params)
  end

  defp metadata_changeset(schema, params) do
    schema
    |> cast(params, @permitted_metadata)
    |> add_uuid()
    |> validate_required(@embedded_metadata_required)
  end
end
