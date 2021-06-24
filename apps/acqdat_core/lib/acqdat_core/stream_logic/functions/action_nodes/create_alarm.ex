defmodule AcqdatCore.StreamLogic.Functions.ActionNodes.CreateAlarm do

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
    message_types: %{
      type: "select",
      source: ["raw_telemetry", "structured_telemetry"],
      default: "",
      required: true
    }
  ]
  @category :action
  @display_name "Message Type Filter"
  @info """
  The nodes checks the `message_type` of the incoming message and verifies it
  with the configuration saved for the node. If the `message_type` matches one
  of the types configured then the message is passed on through the true path, else
  the false path is used. There are multiple message types.

  The incoming data has the following structure.
  {message_type: '', message_payload: '', metadata: ''}

  """

  use Virta.Component

  @impl true
  def run(request_id, inport_args, _outport_args, _instance_pid, properties) do
    params = Map.get(inport_args, :input)
    {request_id, :reply, params}
  end
end
