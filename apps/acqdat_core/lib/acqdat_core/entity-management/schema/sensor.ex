defmodule AcqdatCore.Schema.EntityManagement.Sensor do
  @moduledoc """
  Models a sensor in the system.

  A sensor is responsible for sensing IoT data and sending it to
  server via the gateway. A sensor may belong to an asset. A sensor
  not connected to an asset belongs to the organisation.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.EntityManagement.{Organisation, Project, SensorsData}
  alias AcqdatCore.Schema.EntityManagement.{SensorType}
  alias AcqdatCore.Schema.IotManager.Gateway

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
    field(:description, :string)
    field(:has_timesrs_data, :boolean, default: false)

    embeds_many :metadata, Metadata, on_replace: :delete do
      field(:name, :string, null: false)
      field(:data_type, :string, null: false)
      field(:uuid, :string, null: false)
      field(:unit, :string)
      field(:value, :string)
    end

    # associations
    belongs_to(:org, Organisation, on_replace: :delete)
    belongs_to(:project, Project, on_replace: :delete)
    belongs_to(:gateway, Gateway, on_replace: :delete)
    belongs_to(:sensor_type, SensorType, on_replace: :delete)

    has_one(:sensors_data, SensorsData)

    timestamps(type: :utc_datetime)
  end

  @required_params ~w(org_id project_id sensor_type_id uuid slug name)a
  @optional_params ~w(gateway_id parent_id parent_type description)a

  @embedded_metadata_required ~w(name uuid data_type)a
  @embedded_metadata_optional ~w(unit value)a
  @permitted_metadata @embedded_metadata_optional ++ @embedded_metadata_required

  @permitted @required_params ++ @optional_params

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()

  def changeset(%__MODULE__{} = sensor, params) do
    sensor
    |> cast(params, @permitted)
    |> cast_embed(:metadata, with: &create_metadata_changeset/2)
    |> add_uuid()
    |> add_slug()
    |> validate_required(@required_params)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = sensor, params) do
    sensor
    |> cast(params, @permitted)
    |> cast_embed(:metadata, with: &update_metadata_changeset/2)
    |> validate_required(@required_params)
    |> common_changeset()
  end

  @spec common_changeset(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def common_changeset(changeset) do
    changeset
    |> assoc_constraint(:org)
    |> assoc_constraint(:project)
    |> assoc_constraint(:gateway)
    |> assoc_constraint(:sensor_type)
  end

  defp create_metadata_changeset(schema, params) do
    schema
    |> cast(params, @permitted_metadata)
    |> add_uuid()
    |> validate_required(@embedded_metadata_required)
  end

  defp update_metadata_changeset(schema, params) do
    schema
    |> cast(params, @permitted_metadata)
    |> validate_required(@embedded_metadata_required)
  end
end
