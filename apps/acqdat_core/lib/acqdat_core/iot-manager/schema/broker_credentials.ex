defmodule AcqdatCore.Schema.IotManager.BrokerCredentials do
  @moduledoc """
  Holds the credentials needed to connect with the broker.
  """

  use AcqdatCore.Schema

  @type t :: %__MODULE__{}

  schema("acqdat_broker_credentials") do
    field(:entity_uuid, :string, null: false)
    field(:access_token, :string, null: false)
    field(:entity_type, :string, null: false)

    timestamps(type: :utc_datetime)
  end

  @permitted ~w(entity_uuid access_token entity_type)a

  def changeset(%__MODULE__{} = credentials, params) do
    credentials
    |> cast(params, @permitted)
    |> validate_required(@permitted)
    |> unique_constraint(:entity_uuid, name: :broker_uuid_unique_constraint)
  end

end
