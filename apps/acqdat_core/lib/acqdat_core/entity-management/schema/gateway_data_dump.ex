defmodule AcqdatCore.Schema.EntityManagement.GatewayDataDump do
  @moduledoc """
  Models the schema where initially gateway data will be stored

  Which later will be transferred to gateway actual data table
  depending on the parameters mapped in that gateway.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.EntityManagement.{Gateway, Organisation, Project}

  @typedoc """
  `inserted_timestamp`: The timestamp sent by device sending the gateway data.
  `data`: The data of the gateway.
  """
  @type t :: %__MODULE__{}

  @primary_key false
  schema("acqdat_gateway_data_dump") do
    field(:inserted_timestamp, :utc_datetime, primary_key: true)

    field(:data, :map, null: false)

    # associations
    belongs_to(:gateway, Gateway, on_replace: :raise, primary_key: true)
    belongs_to(:org, Organisation, on_replace: :raise, primary_key: true)
    belongs_to(:project, Project, on_replace: :raise, primary_key: true)

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @required_params ~w(inserted_timestamp gateway_id org_id project_id data)a

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
      name: :acqdat_gateway_data_dump_inserted_timestamp_index,
      message: "data with same time stamp"
    )
  end
end
