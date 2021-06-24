defmodule AcqdatCore.StreamLogic.Functions.FilterNode.CheckFieldExistence do
  @inports [:input]
  @outports [:true, :false]
  @properties [
    label: %{
      type: "input-text",
      default: "",
      required: true
    },
    description: %{
      type: "input-text",
      default: ""
    },
    message_payload: %{
      type: "input-multiple",
      default: [],
      required: true
    },
    metadata: %{
      type: "input-multiple",
      default: [],
      required: true
    },
    check_all_fields: %{
      type: "input-boolean",
      default: false
    }
  ]
  @category :filter
  @display_name "Check Field Existence"
  @info """
  Checks if certain fields exist in the message_payload or metadata.

  {message_type: type, message_payload: payload, metadata: meta}

  e.g.
  {
    message_type: "raw_telemetry"
    message: {energy: {voltage: 230, current: 10} },
    metadata: {device: "xyz"}
  }

  Fields which are inside `message` or `metadata` can be directly be added.
  e.g. "energy" or "device" in the respective message_payload or metadata input
  fields.

  Inorder to check existence of a nested field such as `current` or `voltage`, "."
  notation can be used.
  e.g. to check existence of `energy` and `voltage` the format would be as follows
  "energy.voltage" or "energy.current".

  If the check all fields is selected then the node checks for all the keys configured
  in the metadata and message_payload. If all keys are found then the true path is
  used, else the false path is used.
  """

  use Virta.Component

  @impl true
  def run(request_id, inport_args, _outport_args, _instance_pid, properties) do
    params = Map.get(inport_args, :input)
    {request_id, :reply, params}
  end
end
