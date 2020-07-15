defmodule AcqdatCore.Schema.EntityManagement.SensorsData do
  @moduledoc """
  Models the schema where timeseries related data is stored
  for all the sensors.

  Each row in this table corresponds to a sensor value at
  a particular time, for a particular organisation.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.EntityManagement.{Sensor, Organisation}

  @typedoc """
  `inserted_timestamp`: The timestamp sent by device sending the sensor data.
  `parameters`: The different parameters of the sensor.
  """
  @type t :: %__MODULE__{}

  @primary_key false
  schema("acqdat_sensors_data") do
    field(:inserted_timestamp, :utc_datetime, primary_key: true)

    embeds_many :parameters, Parameters do
      field(:name, :string, null: false)
      field(:uuid, :string, null: false)
      field(:data_type, :string, null: false)
      field(:value, :integer, null: false)
    end

    # associations
    belongs_to(:sensor, Sensor, on_replace: :raise, primary_key: true)
    belongs_to(:org, Organisation, on_replace: :raise, primary_key: true)

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @required_params ~w(inserted_timestamp sensor_id org_id)a
  @embedded_required_params ~w(name uuid data_type value)a

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = sensor_data, params) do
    sensor_data
    |> cast(params, @required_params)
    |> cast_embed(:parameters, with: &parameters_changeset/2)
    |> validate_required(@required_params)
    |> assoc_constraint(:sensor)
    |> assoc_constraint(:org)
  end

  def parameters_changeset(schema, params) do
    schema
    |> cast(params, @embedded_required_params)
    |> validate_required(@embedded_required_params)
  end
end
