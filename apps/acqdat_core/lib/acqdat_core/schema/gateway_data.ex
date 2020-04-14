defmodule AcqdatCore.Schema.GatewayData do
  @moduledoc """
  Models the schema where timeseries related data is stored
  for all the gateway.

  Each row in this table corresponds to a gateway value at
  a particular time, for a particular organisation.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.{Gateway, Organisation}

  @typedoc """
  `inserted_timestamp`: The timestamp sent by device sending the gateway data.
  `parameters`: The different parameters of the gateway.
  """
  @type t :: %__MODULE__{}

  @primary_key false
  schema("acqdat_gateway_data") do
    field(:inserted_timestamp, :utc_datetime, primary_key: true)

    embeds_one :parameters, Parameters do
      field(:name, :string, null: false)
      field(:uuid, :string, null: false)
      field(:data_type, :string, null: false)
      field(:value, :string, null: false)
    end

    # associations
    belongs_to(:gateway, Gateway, on_replace: :delete, primary_key: true)
    belongs_to(:org, Organisation, on_replace: :delete, primary_key: true)

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @required_params ~w(inserted_timestamp gateway_id org_id)a
  @embedded_required_params ~w(name uuid data_type value)a

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = gateway_data, params) do
    gateway_data
    |> cast(params, @required_params)
    |> cast_embed(:parameters, with: &parameters_changeset/2)
    |> validate_required(@required_params)
    |> assoc_constraint(:gateway)
    |> assoc_constraint(:org)
  end

  defp parameters_changeset(schema, params) do
    schema
    |> cast(params, @embedded_required_params)
    |> add_uuid()
    |> validate_required(@embedded_required_params)
  end

  defp add_uuid(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> put_change(:uuid, UUID.uuid1(:hex))
  end
end
