defmodule AcqdatCore.Schema.Sensor do
  @moduledoc """
  Models a sensor in the system.

  A sensor is responsible for sensing IoT data and sending it to
  server via the gateway. A sensor may belong to an asset. A sensor
  not connected to an asset belongs to the organisation.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.{Gateway, Organisation}

  @typedoc """
  `uuid`: A universallly unique id for the sensor.
  `name`: A unique name for sensor per device. Note the same
          name can be used for sensor associated with another
          device.
  `parent_type`: The type of entity to which the sensor belongs. A parent
          could be an `asset` or `organisation`.
  `parent_id`: Id of the `parent_entity`.
  `parameters`: The different parameters of the sensor.
  """
  @type t :: %__MODULE__{}

  schema("acqdat_sensors") do
    field(:uuid, :string, null: false)
    field(:slug, :string, null: false)
    field(:name, :string)
    field(:parent_id, :integer)
    field(:parent_type, :string)

    embeds_many :parameters, Parameters do
      field(:name, :string, null: false)
      field(:uuid, :string, null: false)
      field(:data_type, :string, null: false)
    end

    # associations
    belongs_to(:org, Organisation, on_replace: :delete)
    belongs_to(:gateway, Gateway, on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(org_id uuid slug name)a
  @optional_params ~w(gateway_id parent_id parent_type)a
  @embedded_required_params ~w(name uuid data_type)a

  @permitted @required_params ++ @optional_params

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = sensor, params) do
    sensor
    |> cast(params, @permitted)
    |> cast_embed(:parameters, with: &parameters_changeset/2)
    |> add_uuid()
    |> add_slug()
    |> validate_required(@required_params)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = sensor, params) do
    sensor
    |> cast(params, @permitted)
    |> cast_embed(:parameters, with: &parameters_changeset/2)
    |> validate_required(@required_params)
    |> common_changeset()
  end

  def common_changeset(changeset) do
    changeset
    |> assoc_constraint(:org)
    |> assoc_constraint(:gateway)
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
    |> cast(params, @embedded_required_params)
    |> add_uuid()
    |> validate_required(@embedded_required_params)
  end
end
