defmodule AcqdatCore.Schema.EntityManagement.SensorsData do
  @moduledoc """
  Models the schema where timeseries related data is stored
  for all the sensors.

  Each row in this table corresponds to a sensor value at
  a particular time, for a particular organisation.
  """

  use AcqdatCore.Schema

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
    field(:sensor_id, :integer, primary_key: true)
    field(:org_id, :integer, primary_key: true)
    field(:project_id, :integer, primary_key: true)

    field(:sensor_parent_id, :integer, virtual: true)
    field(:sensor_name, :string, virtual: true)

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @required_params ~w(inserted_timestamp sensor_id org_id project_id)a
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
  end

  def parameters_changeset(schema, params) do
    schema
    |> cast(params, @embedded_required_params)
    |> validate_required(@embedded_required_params)
  end
end
