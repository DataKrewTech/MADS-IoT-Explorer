defmodule Virta.Math.ConstantAdd do
  @inports [:addend, :augend]
  @outports [:sum]
  @properties [
    constant: %{
      type: "integer",
      default: 0
    }
  ]

  @category :test
  @info "Adds two real numbers and add the constant to the result"
  @display_name "Add"

  use Virta.Component

  @impl true
  def run(request_id, inport_args, _outport_args, _instance_pid, configuration) do
    value = Map.get(inport_args, :augend) + Map.get(inport_args, :addend) +
      configuration.constant
    {request_id, :reply, %{sum: value}}
  end
end
