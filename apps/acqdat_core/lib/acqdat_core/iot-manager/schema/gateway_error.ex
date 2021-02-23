defmodule AcqdatCore.Schema.IoTManager.GatewayError do
  @moduledoc """
  Schema to define errors for a gateway.

  Errors occur if data is not being sent correctly for a gateway. The error details
  are stored in the db so the user can see and take corrective actions.
  """

  use AcqdatCore.Schema

  schema("acqdat_gateway_error") do
    field(:error_key, :string)
  end
end
