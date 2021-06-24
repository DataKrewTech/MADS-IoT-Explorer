defmodule AcqdatCore.StreamLogic.Functions.FilterNode.OriginatorTypeFilter do
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
      source: ["gateway", "sensor"],
      required: true
    }
  ]
  @category :filter
  @display_name "Originator Type Filter"
  @info """
  The nodes checks the `originator_type` of the incoming message and verifies it
  with the configuration saved for the node. If the `originator_type` matches one
  of the types configured then the message is passed on through the true path, else
  the false path is used. Their are multiple message types.

  The originator_type key is present in the message metadata.
  """

  use Virta.Component

  @impl true
  def run(request_id, inport_args, _outport_args, _instance_pid, properties) do
    params = Map.get(inport_args, :input)
    {request_id, :reply, params}
  end
end
