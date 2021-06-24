defmodule AcqdatCore.StreamLogic.Functions.FilterNode.ScriptTest do
  use ExUnit.Case, async: true
  alias AcqdatCore.StreamLogic.Token
  alias AcqdatCore.StreamLogic.Functions.StartNode
  alias AcqdatCore.StreamLogic.Functions.FilterNode.Script

  alias Virta.Node
  alias Virta.Registry
  alias Virta.EdgeData
  alias Virta.Core.Out

  describe "filter script: " do
    setup do
      payload = %{hum: 20, temp: 30}
      type = :raw_telemetry
      metadata = %{device_id: 1234}
      data = [message_type: type, message_payload: payload, metadata: metadata]
      {:ok, token} = Token.new(data)
      node1 = %Node{module: StartNode, id: 0}
      node3 = %Node{module: Out, id: 3}
      node4 = %Node{module: Out, id: 4}
      [token: token, node1: node1, node3: node3, node4: node4]
    end

    test "if script returns true data sent on true path", context do
      %{token: token, node1: node1, node3: node3, node4: node4} = context
      js_script = """
        function check(payload) {
          return payload > 10;
        }
        return check(message_payload.hum)
        """
      configuration = %{script: js_script}
      node2 = %Node{module: Script, id: 1, configuration: configuration}
      graph = create_graph(node1, node2, node3, node4)

      name = "script_test"
      data = %{
        node1 => [{1, :std_in, token}]
      }

      {:ok, "registered"} = Registry.register(name, graph)
      {request_id, output} = Virta.Executor.call(name, data)
      Registry.unregister(name)
      assert %{
        node3out: %AcqdatCore.StreamLogic.Token{
          message_payload: %{hum: 20, temp: 30},
          message_type: :raw_telemetry,
          metadata: %{device_id: 1234}
        } } == output
    end

    test "if script returns false data sent on false path", context do
      %{token: token, node1: node1, node3: node3, node4: node4} = context
      js_script = """
        function check(payload) {
          return payload > 30;
        }
        return check(message_payload.hum)
        """
      configuration = %{script: js_script}
      node2 = %Node{module: Script, id: 1, configuration: configuration}
      graph = create_graph(node1, node2, node3, node4)

      name = "script_test"
      data = %{
        node1 => [{1, :std_in, token}]
      }

      {:ok, "registered"} = Registry.register(name, graph)
      {request_id, output} = Virta.Executor.call(name, data)
      Registry.unregister(name)
      assert %{
        node4out: %AcqdatCore.StreamLogic.Token{
          message_payload: %{hum: 20, temp: 30},
          message_type: :raw_telemetry,
          metadata: %{device_id: 1234}
        } } == output
    end
  end

  defp create_graph(node1, node2, node3, node4) do
    Graph.new(type: :directed)
    |> Graph.add_edge(
      node1,
      node2,
      label: %EdgeData{from: :std_out, to: :input}
    )
    |> Graph.add_edge(
      node2,
      node3,
      label: %EdgeData{from: :true, to: :node3out}
    )
    |> Graph.add_edge(
      node2,
      node4,
      label: %EdgeData{from: :false, to: :node4out}
    )
  end
end
