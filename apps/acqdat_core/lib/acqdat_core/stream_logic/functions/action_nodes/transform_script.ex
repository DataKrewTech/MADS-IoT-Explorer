defmodule AcqdataCore.StreamLogic.Functions.ActionNodes.TransformScript do
  @inports [:input]
  @outports [:script_output]
  @properties [
     label: %{
      type: "text",
      default: "",
      required: true
    },
    description: %{
      type: "text",
      default: ""
    },
    script: %{
      type: "jsscript",
      default: "return {message_type: '', message_payload: '', metadata: ''}"
    }
  ]
  @category :action
  @display_name "Transform Script"
  @info """
  Transforms the incoming message and returns a new message.

  The incoming data has the following structure.
  {message_type: type, message_payload: payload, metadata: meta}

  The business logic to transform the incoming script can be configured here.
  The script should return the message in the same format as the input i.e.
  {message_type: type, message_payload: payload, metadata: meta}
  """

  use Virta.Component

  @impl true
  def run(request_id, inport_args, _outport_args, _instance_pid, properties) do
    params = Map.get(inport_args, :input)
    {request_id, :reply, params}
  end
end
