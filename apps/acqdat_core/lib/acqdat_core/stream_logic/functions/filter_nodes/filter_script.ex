defmodule AcqdatCore.StreamLogic.Functions.FilterNode.Script do
  @moduledoc """
  Evaluates the defined script for the incoming message and channels it across the
  true or false path.

  __Note__ The script should return a `true` or `false` value.
  """
  @inports [:input]
  @outports [:true, :false]
  @properties [
    label: %{
      type: "input-text",
      default: "",
      required: true
    },
    description: %{
      type: "input-text",
      default: ""
    },
    script: %{
      type: "jsscript",
      default: "return message_payload.temperature > 20",
      required: true
    }
  ]
  @category :filter
  @display_name "Script"
  @info """
  Evaluates the defined script for the incoming message and channels it across
  the true or false path.

  The incoming data has the following structure.
  {message_type: type, message_payload: payload, metadata: meta}

  A key inside the message_payload can be accessed to run comparisons
  e.g. message_payload.value > 10.
  Similarly, a key inside the metadata can be accesses as metadata.value and
  comparisons can be done.

  __Note__ The script should return a `true` or `false` value.
  """

  use Virta.Component

  @impl true
  def run(request_id, inport_args, _outport_args, _instance_pid, properties) do
    params = Map.get(inport_args, :input)
    result = execute_js_function(properties.script, params)
    {request_id, :reply, %{result: result, data: params}}
  end

  def dispatch({request_id, :reply, %{result: false, data: data}}, outport_args) do
    outport_args
    |> Enum.map(fn
      %{from: false, pid: pid, to: to} ->
        send(pid, {request_id, to, data})
      _ -> :ok
    end)
  end

  def dispatch({request_id, :reply, %{result: true, data: data}}, outport_args) do
    outport_args
    |> Enum.map(fn
      %{from: true, pid: pid, to: to} ->
        send(pid, {request_id, to, data})
      _ -> :ok
    end)
  end

  ############################## private functions ###############
  defp execute_js_function(script, params) do
    function = """
    function filter_script(message_payload, message_type, metadata) {
      #{script}
    }
    """
    context = Execjs.compile(function)
    result = Execjs.call(context, "filter_script",
      [params.message_payload, params.message_type, params.metadata])

    if result do
      true
    else
      false
    end
  end

end
