defmodule AcqdataCore.StreamLogic.Functions.ActionNodes.SaveTimeSeries do
  @inports [:input]
  @outports [:timeseries_output]
  @properties [
     label: %{
      type: "input-text",
      default: "",
      required: true
    },
    description: %{
      type: "input-text",
      default: ""
    }
  ]
  @category :action
  @display_name "Save Timeseries"
  @info """
  Stores the data in timeseries database.
  """

  use Virta.Component

  @impl true
  def run(request_id, inport_args, _outport_args, _instance_pid, properties) do
    params = Map.get(inport_args, :input)
    {request_id, :reply, params}
  end
end
