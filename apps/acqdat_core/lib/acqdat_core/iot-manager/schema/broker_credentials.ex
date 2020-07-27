defmodule AcqdatCore.Schema.IotManager.BrokerCredentials do
  @moduledoc """
  Holds the credentials needed to connect with the broker.
  """

  use AcqdatCore.Schema
  @entity_type ~w(Project Gateway)s

  @type t :: %__MODULE__{}

  schema("acqdat_broker_credentials") do
    field(:entity_uuid, :string, null: false)
    field(:access_token, :string, null: false)
    field(:entity_type, :string, null: false)
    field(:subscriptions, {:array, :map})

    timestamps(type: :utc_datetime)
  end

  @required ~w(entity_uuid access_token entity_type)a
  @optional ~w(subscriptions)a

  @permitted @required ++ @optional
  def changeset(%__MODULE__{} = credentials, params) do
    credentials
    |> cast(params, @permitted)
    |> validate_required(@required)
    |> validate_inclusion(:entity_type, @entity_type)
    |> unique_constraint(:entity_uuid, name: :broker_uuid_unique_constraint)
  end
end
