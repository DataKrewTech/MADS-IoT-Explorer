defmodule VernemqMadsPlugin.GatewaySchema do
  @moduledoc """
  Module to read data for gateway.
  """

  use Ecto.Schema

  schema "acqdat_gateway" do
    field(:uuid, :string, null: false)
    field(:access_token, :string, null: false)
    field(:name, :string)
  end

end
