defmodule AcqdatCore.DataCruncher.Functions.Email do
  @inports [:ts_datasource]
  @outports [:tsemail]
  @display_name "Send Email"
  @properties %{}
  @category :async_output
  @info """
  Function sends the email as output node
  """

  use Virta.Component
  alias AcqdatCore.Repo

  def run(request_id, inport_args, _outport_args, _instance_pid) do
    result = Map.get(inport_args, :ts_datasource)
    {request_id, :reply, %{tsemail: result}}
  end
end
