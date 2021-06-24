defmodule AcqdatCore.StreamLogic.Token do
  @moduledoc """
  Models a message token passing through differnt nodes inside a workflow.

  The token provides a structure to the message passing through different nodes.

  **Note**
  Please make use of `Token.new: 1` for creating `token` struct instead of creating
  directly as it provides certain checks on the token keys.
  """
  @message_types ~w(
    structured_telemetry
    raw_telemetry
  )a

  @enforce_keys [:message_type, :message_payload, :metadata]
  defstruct ~w(
    message_type
    message_payload
    metadata
  )a

  @typedoc """
  * `:message_type`: The type of message can be one of the following type.
          - `structured_telemetry`
          - `raw_telemetry`
  * `:message_payload`: the telemetry payload
  * `:metadata`: extra information about the message.
  """
  @type t :: %__MODULE__{
    message_type: String.t(),
    message_payload: map,
    metadata: map
  }

  def new(opts) when opts == [] do
    {:error, "expect data and data_type"}
  end

  def new(opts) do
    if valid_data_type?(Keyword.fetch(opts, :message_type)) do
      {:ok, struct(%__MODULE__{
        message_type: "",
        message_payload: %{},
        metadata: %{}
      }, opts)}
    else
      {:error, "invalid message type"}
    end
  end

  def valid_data_types?(:error), do: false

  def valid_data_type?({:ok, message_type}) do
    Enum.member?(@message_types, message_type)
  end
end
