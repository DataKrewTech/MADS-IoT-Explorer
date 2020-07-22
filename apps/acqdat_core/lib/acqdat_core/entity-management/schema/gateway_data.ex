defmodule AcqdatCore.Schema.EntityManagement.GatewayData do
  @moduledoc """
  Models the schema where timeseries related data is stored
  for all the gateway.

  Each row in this table corresponds to a gateway value at
  a particular time, for a particular organisation.
  """

  use AcqdatCore.Schema

  @typedoc """
  `inserted_timestamp`: The timestamp sent by device sending the gateway data.
  `parameters`: The different parameters of the gateway.
  """
  @type t :: %__MODULE__{}

  @primary_key false
  schema("acqdat_gateway_data") do
    field(:inserted_timestamp, :utc_datetime, primary_key: true)

    embeds_many :parameters, Parameters do
      field(:name, :string, null: false)
      field(:uuid, :string, null: false)
      field(:data_type, :string, null: false)
      field(:value, :integer, null: false)
    end

    # associations
    field(:gateway_id, :integer, primary_key: true)
    field(:org_id, :integer, primary_key: true)
    field(:project_id, :integer, primary_key: true)

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @required_params ~w(inserted_timestamp gateway_id org_id project_id)a
  @embedded_required_params ~w(name uuid data_type value)a

  def changeset(%__MODULE__{} = gateway_data, params) do
    gateway_data
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
