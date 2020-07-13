defmodule AcqdatCore.Schema.IotManager.Gateway do
  @moduledoc """
  Models a Gateway in the system.

  A Gateway can be any entity which receives data from sensor and send data
  to and forth in our given platform.
  """
  use AcqdatCore.Schema

  alias AcqdatCore.Schema.EntityManagement.{Organisation, Project}

  @typedoc """
  `uuid`: A universally unique id to identify the gateway.
  `name`: Name for easy identification of the gateway.
  `access_token`: Access token to be used while sending data
              to server from the gateway.
  """
  @type t :: %__MODULE__{}

  @parent_type ~w(Project Asset)s
  @channel ~w(http mqtt)s

  schema("acqdat_gateway") do
    field(:uuid, :string, null: false)
    field(:slug, :string, null: false)
    field(:name, :string)
    field(:parent_type, :string)
    field(:parent_id, :integer)
    field(:description, :string)
    field(:access_token, :string, null: false)
    field(:serializer, :map)

    field(:current_location, :map)
    field(:channel, :string, null: false)
    field(:status, :integer, virtual: true)
    field(:image_url, :string)
    field(:image, :any, virtual: true)
    field(:static_data, {:array, :map})

    embeds_many :streaming_data, StreamingData, on_replace: :delete do
      field(:name, :string, null: false)
      field(:uuid, :string, null: false)
      field(:data_type, :string, null: false)
      field(:unit, :string)
    end

    field(:mapped_parameters, :map)

    # associations
    belongs_to(:org, Organisation, on_replace: :delete)
    belongs_to(:project, Project, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(name access_token slug uuid org_id project_id channel parent_id parent_type)a
  @optional_params ~w(description serializer current_location image_url static_data mapped_parameters)a
  @embedded_required_params ~w(name uuid data_type)a
  @embedded_optional_params ~w(unit)a
  @permitted_embedded @embedded_optional_params ++ @embedded_required_params
  @permitted @required_params ++ @optional_params

  def changeset(%__MODULE__{} = gateway, params) do
    gateway
    |> cast(params, @permitted)
    |> cast_embed(:streaming_data, with: &parameters_changeset/2)
    |> add_uuid()
    |> add_slug()
    |> validate_inclusion(:parent_type, @parent_type)
    |> validate_inclusion(:channel, @channel)
    |> validate_required(@required_params)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = gateway, params) do
    gateway
    |> cast(params, @permitted)
    |> cast_embed(:streaming_data, with: &parameters_changeset/2)
    |> validate_required(@required_params)
    |> validate_inclusion(:parent_type, @parent_type)
    |> validate_inclusion(:channel, @channel)
    |> common_changeset()
  end

  def common_changeset(changeset) do
    changeset
    |> assoc_constraint(:org)
    |> assoc_constraint(:project)
    |> unique_constraint(:slug, name: :acqdat_gateway_slug_index)
    |> unique_constraint(:uuid, name: :acqdat_gateway_uuid_index)
    |> unique_constraint(:access_token, name: :acqdat_gateway_access_token_index)
    |> unique_constraint(:name, name: :acqdat_gateway_name_org_id_project_id_index)
  end

  defp add_uuid(changeset) do
    changeset
    |> put_change(:uuid, UUID.uuid1(:hex))
  end

  defp add_slug(changeset) do
    changeset
    |> put_change(:slug, Slugger.slugify(random_string(12)))
  end

  defp parameters_changeset(schema, params) do
    schema
    |> cast(params, @permitted_embedded)
    |> add_uuid()
    |> validate_required(@embedded_required_params)
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end
end
