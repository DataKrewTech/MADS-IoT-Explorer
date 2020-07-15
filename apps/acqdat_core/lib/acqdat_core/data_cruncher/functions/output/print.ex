defmodule AcqdatCore.DataCruncher.Functions.Print do
  @inports [:ts_datasource]
  @outports [:tsprint]
  @display_name "Print Output"
  @properties %{}
  @category :sync_output
  @info """
  Function Returns the print output value
  """

  use Virta.Component
  alias AcqdatCore.Repo

  def run(request_id, inport_args, _outport_args, _instance_pid) do
    result = Map.get(inport_args, :ts_datasource)
    {request_id, :reply, %{tsprint: result}}
  end
end
