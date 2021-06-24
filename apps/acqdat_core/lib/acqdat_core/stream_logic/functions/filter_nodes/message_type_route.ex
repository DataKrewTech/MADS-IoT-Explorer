defmodule AcqdatCore.StreamLogic.Functions.FilterNode.MessageTypeRoute do
  @inports [:input]
  @outports [:raw_telemetry, :structured_telemetry]
  @properties []
  @category :filter
  @display_name "Message Type Filter"
  @info """
  The node route messages to different paths depending the on the way connection
  between different outgoing paths has been done.
  """

  use Virta.Component

  @impl true
  def run(request_id, inport_args, _outport_args, _instance_pid, properties) do
    params = Map.get(inport_args, :input)
    {request_id, :reply, params}
  end
end
