defmodule AcqdataCore.StreamLogic.Functions.ActionNodes.SMS do
  @inports [:sms_input]
  @outports [:sms_output]
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
    phone_numbers: %{
     type: "input-multiple",
     default: [],
     required: true
    },
    template: %{
      type: "input-text",
      default: ""
    }
  ]
  @category :action
  @display_name "SMS"
  @info """
  The node sends an SMS to the phone numbers configured.

  While using the node a template can be specified. The incoming message has the
  following structure.
  {message_type: type, message_payload: payload, metadata: meta}

  The incoming data can be interpolated inside the message string adding placeholders
  in the following manner
  "The temperature levels have increased by \#{message_payload.temperature}"

  The '\#{}' helps to interpolate values from the message in the actual message to
  be sent via SMS.
  """

  use Virta.Component

  @impl true
  def run(request_id, inport_args, _outport_args, _instance_pid, properties) do
    params = Map.get(inport_args, :input)
    {request_id, :reply, params}
  end
end
