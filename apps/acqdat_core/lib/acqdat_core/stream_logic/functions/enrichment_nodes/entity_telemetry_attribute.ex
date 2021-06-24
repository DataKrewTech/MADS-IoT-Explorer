defmodule AcqdataCore.StreamLogic.Functions.ActionNodes.EntityTelemetryAttributes do
  @inports [:input]
  @outports [:success, :failure]
  @properties [
    entity_param: %{
      type: "input-multiple",
      default: [],
      required: true
    },
    all_similar_type_allow: %{
      type: "input-boolean",
      default: true,
    },
    fetch_mode: %{
      type: "select",
      source: ["first", "last", "all"],
      default: "all"
    },
    entity: %{
      type: "select",
      source: ["gateway", "sensor"],
      required: true
    },
  ]
  @category :enrichment
  @display_name "Entity Telemetry"
  @info """
  Adds telemetry from an entity in the metadata. The entity and it's parameter
  can be selected. If no selection is done then originator and all it's telemetry
  parameters are added to the metadata portion of the message.

  In case entity telemetry data is not found the message is sent on the failure
  path.

  An optional `all_similar_type_allow` flag can be set to load the telemetry for
  all entities of the same type. At present only `sensor` entities are supported for this
  flag. In case the flag is set all the sensors belonging to a sensor type will have
  the metadata enriched with their telemetry attributes.
  """

  use Virta.Component

  @impl true
  def run(request_id, inport_args, _outport_args, _instance_pid, properties) do
    params = Map.get(inport_args, :input)
    {request_id, :reply, params}
  end
end
