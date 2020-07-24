defmodule VernemqMadsPlugin.BrokerCredentials do
  @moduledoc """
  Module to read data for gateway.
  """

  use Ecto.Schema

  schema("acqdat_broker_credentials") do
    field(:entity_uuid, :string, null: false)
    field(:access_token, :string, null: false)
    field(:entity_type, :string, null: false)

    timestamps(type: :utc_datetime)
  end

end
