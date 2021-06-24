defmodule AcqdataCore.StreamLogic.Functions.ActionNodes.EntityAttributes do
  @inports [:input]
  @outports [:success, :failure]
  @properties []
  @category :enrichment
  @display_name "Entity Attributes"
  @info """
  Adds an entity attribute in the metadata portion of the message.
  An entity could be a project, sensor or asset.
  """

  use Virta.Component

  @impl true
  def run(request_id, inport_args, _outport_args, _instance_pid, properties) do
    params = Map.get(inport_args, :input)
    {request_id, :reply, params}
  end
end
