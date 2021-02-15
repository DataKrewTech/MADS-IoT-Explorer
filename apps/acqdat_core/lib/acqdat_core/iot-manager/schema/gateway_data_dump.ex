defmodule AcqdatCore.Schema.IotManager.GatewayDataDump do
  @moduledoc """
  Purpose:-

  Models the schema where initially gateway data will be stored
  as a data dump which later will be transferred to gateway actual data table
  parsed according to the parameters mapped in that gateway.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.EntityManagement.{Organisation, Project}
  alias AcqdatCore.Schema.IotManager.Gateway
  alias AcqdatCore.Schema.IotManager.EctoType.UnixTimestamp

  @typedoc """
  `inserted_timestamp`: The timestamp sent by device sending the gateway data.
  `data`: The data of the gateway.
  """
  @type t :: %__MODULE__{}

  @primary_key false
  schema("acqdat_gateway_data_dump") do
    field(:inserted_timestamp, UnixTimestamp, primary_key: true)

    field(:data, :map, null: false)

    # associations
    belongs_to(:gateway, Gateway,
      on_replace: :raise,
      primary_key: true,
      foreign_key: :gateway_uuid,
      references: :uuid,
      type: :string
    )

    belongs_to(:org, Organisation,
      on_replace: :raise,
      primary_key: true,
      references: :uuid,
      foreign_key: :org_uuid,
      type: :string
    )

    belongs_to(:project, Project,
      on_replace: :raise,
      primary_key: true,
      references: :uuid,
      foreign_key: :project_uuid,
      type: :string
    )

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @required_params ~w(inserted_timestamp gateway_uuid org_uuid project_uuid data)a

  @spec changeset(
          __MODULE__.t(),
          map
        ) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = gateway_data, params) do
    gateway_data
    |> cast(params, @required_params)
    |> validate_required(@required_params)
    |> assoc_constraint(:gateway)
    |> assoc_constraint(:org)
    |> assoc_constraint(:project)
    |> unique_constraint(:inserted_timestamp,
      name: :acqdat_gateway_data_dump_inserted_timestamp_gateway_uuid_index,
      message: "duplicate data with same timestamp inserted")
  end
end
