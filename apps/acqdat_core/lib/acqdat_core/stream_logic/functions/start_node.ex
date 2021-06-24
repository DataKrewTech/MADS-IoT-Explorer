defmodule AcqdatCore.StreamLogic.Functions.StartNode do
  @moduledoc """
  Node which starts a logic chain.
  """

  @inports [:std_in]
  @outports [:std_out]
  @properties []
  @category :input
  @display_name "Input"
  @info """
  Node starts the logic Chain.
  """

  use Virta.Component

  @impl true
  def run(request_id, inport_args, _outport_args, _instance_pid, _configuration) do
    input_args = Map.get(inport_args, :std_in)
    {request_id, :reply, %{std_out: input_args}}
  end
end
