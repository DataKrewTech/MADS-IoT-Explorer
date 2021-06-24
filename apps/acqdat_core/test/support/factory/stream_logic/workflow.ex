defmodule AcqdatCore.Factory.Workflow do
  defmacro __using__(_options) do
    alias AcqdatCore.StreamLogic.Schema.Workflow
    alias AcqdatCore.StreamLogic.Schema.Workflowgraph

    quote do
      def digraph_factory() do
        %Workflowgraph{
          edge_list: [],
          vertices: []
        }
      end

      def workflow_factory() do
        %Workflow{
          name: sequence(:sl_workflow_name, &"workflow#{&1}"),
          description: "",
          digraph: build(:digraph),
          project: build(:project),
          org: build(:project),
          uuid: UUID.uuid1(:hex),
          enabled: true,
          metadata: %{}
        }
      end

      def create_digraph() do
        from_id = UUID.uuid1(:hex)
        to_id = UUID.uuid1(:hex)
        %{
          edge_list: [
            %{
              source_id: from_id,
              target_id: to_id,
              label: %{from: :std_out, to: :true}
            }
          ],
          vertices: [
             %{
              uuid: from_id,
              label: "Start Node",
              module: "Elixir.AcqdatCore.StreamLogic.Functions.StartNode",
              description: "",
              configuration: %{}
            },
            %{
              uuid: to_id,
              label: "ScriptNode",
              module: "Elixir.AcqdatCore.StreamLogic.Functions.FilterNode.Script",
              description: "",
              configuration: %{
                js_script: """
                  function check(payload) {
                    return payload > 10;
                  }
                  return check(message_payload.hum)
                """
              }
            }
          ]
        }
      end
    end
  end
end
