defmodule Virta.Math.Add do
  @inports [:addend, :augend]
  @outports [:sum]
  @properties []
  @category :test
  @info "Adds two real numbers"
  @display_name "Add"

  use Virta.Component

  @impl true
  def run(request_id, inport_args, _outport_args, _instance_pid, _configuration) do
    value = Map.get(inport_args, :augend) + Map.get(inport_args, :addend)
    {request_id, :reply, %{sum: value}}
  end
end
