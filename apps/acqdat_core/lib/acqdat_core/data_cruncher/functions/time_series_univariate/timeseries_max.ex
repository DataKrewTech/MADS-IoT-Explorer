defmodule AcqdatCore.DataCruncher.Functions.TSMax do

  @inports [:ts_datasource]
  @outports [:tsmax]

  use Virta.Component

  def run(request_id, inport_args, _outport_args, _instance_pid) do
  end
end
