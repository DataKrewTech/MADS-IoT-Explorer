defmodule AcqdataCore.StreamLogic.Functions.ActionNodes.Email do
  @inports [:email_input]
  @outports [:email_output]
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
    email_addresses: %{
      type: "input-multiple",
      default: [],
      required: true
    },
    template: %{
      type: "html-input",
      default: ""
    }
  ]

  @category :action
  @display_name "Email"
  @info """
  The node sends an email to the phone numbers configured.

  While using the node a template can be specified. The incoming message has the
  following structure.
  {message_type: type, message_payload: payload, metadata: meta}

  The Email template can be specified as html.
  """

  use Virta.Component

  @impl true
  def run(request_id, inport_args, _outport_args, _instance_pid, properties) do
    params = Map.get(inport_args, :input)
    {request_id, :reply, params}
  end
end
