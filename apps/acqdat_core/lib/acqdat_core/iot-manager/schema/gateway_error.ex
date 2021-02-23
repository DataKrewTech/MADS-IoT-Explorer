defmodule AcqdatCore.Schema.IoTManager.GatewayError do
  @moduledoc """
  Schema to define errors for a gateway.

  Errors occur if data is not being sent correctly for a gateway. The error details
  are stored in the db so the user can see and take corrective actions.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.IotManager.Gateway

  schema("acqdat_gateway_error") do
    field(:data, :map)
    field(:error, :map)

    belongs_to(:gateway, Gateway,
      on_replace: :raise,
      primary_key: true,
      foreign_key: :gateway_uuid,
      references: :uuid,
      type: :string
    )

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @required ~w(data error gateway_uuid)a

  def changeset(%__MODULE__{} = data, params) do
    data
    |> cast(params, @required)
    |> validate_required(@required)
  end

end
