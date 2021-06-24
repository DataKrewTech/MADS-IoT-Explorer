defmodule Virta.Math.Multiply do
  @inports [:multiplicand, :multiplier]
  @outports [:product]
  @properties %{}
  @category :test
  @info "Multiplies two real numbers"
  @display_name "Multiply"

  use Virta.Component

  @impl true
  def run(request_id, inport_args, _outport_args, _instance_pid, _configuration) do
    value = Map.get(inport_args, :multiplier) * Map.get(inport_args, :multiplicand)
    {request_id, :reply, %{product: value}}
  end
end
