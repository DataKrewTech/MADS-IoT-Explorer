defmodule AcqdatCore.DataCruncher.Functions.TSMax do

  @inports [:ts_datasource]
  @outports [:tsmax]

  use Virta.Component

  def run(request_id, inport_args, _outport_args, _instance_pid) do
    data_source = Map.get(inport_args, :ts_datasource)
    result = process(data_source)
    # {request_id, :reply, %{max_value: result}}
  end

  defp process(data) do

  end


end
