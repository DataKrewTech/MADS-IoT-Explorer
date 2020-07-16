defmodule AcqdatCore.DataCruncher.Domain.WorkflowTest do
  use ExUnit.Case, async: false
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  import AcqdatCore.Test.Support.SensorsData
  alias AcqdatCore.DataCruncher.Functions.TSMax
  alias AcqdatCore.DataCruncher.Functions.TSMin
  alias AcqdatCore.DataCruncher.Functions.Print
  alias AcqdatCore.DataCruncher.Functions.Email
  alias Virta.Core.Out
  alias Virta.{Node, EdgeData}
  alias AcqdatCore.DataCruncher.Domain.Workflow
  alias AcqdatCore.DataCruncher.Model.Dataloader
  alias AcqdatCore.DataCruncher.Token

  describe "register/2" do
    test "registers a workflow" do
      node_from = %Node{module: TSMax, id: UUID.uuid1(:hex)}
      node_to = %Node{module: Out, id: UUID.uuid1(:hex)}
      graph = create_graph(node_from, node_to)
      workflow_id = UUID.uuid1(:hex)
      {:ok, message} = Workflow.register(workflow_id, graph)
      assert message == "registered"
    end
  end

  describe "execute/1" do
    setup :setup_sensor_with_type
    setup :put_sensor_data

    @tag timeout: :infinity
    @tag sensor_data_quantity: 10
    @tag time_interval_seconds: 5

    test "executes a workflow succesfully", context do
      %{sensor: sensor} = context
      node_from = %Node{module: TSMax, id: UUID.uuid1(:hex)}
      node_to = %Node{module: Out, id: UUID.uuid1(:hex)}
      [param | _] = sensor.sensor_type.parameters

      edge_list = [
        {%Node{module: TSMax, id: "tamshh"}, %Node{module: Print, id: "print43454"},
         label: %EdgeData{from: :tsmax, to: :ts_datasource}},
        {%Node{module: Print, id: "print43454"}, %Node{module: Out, id: "outnoderfr"},
         label: %EdgeData{from: :tsprint, to: :print43454}},
        {%Node{module: TSMax, id: "tamshh"}, %Node{module: Email, id: "email bhgb"},
         label: %EdgeData{from: :tsmax, to: :ts_datasource}},
        {%Node{module: Email, id: "email bhgb"}, %Node{module: Out, id: "outnoderfr"},
         label: %EdgeData{from: :tsemail, to: :email_bhgb}},
        {%Node{module: TSMin, id: "miniden"}, %Node{module: Print, id: "print6555"},
         label: %EdgeData{from: :tsmin, to: :ts_datasource}},
        {%Node{module: Print, id: "print6555"}, %Node{module: Out, id: "outnoderfr"},
         label: %EdgeData{from: :tsprint, to: :print6555}}
      ]

      graph =
        Graph.new(type: :directed)
        |> Graph.add_edges(edge_list)

      graph_data =
        prepare_graph_data(
          sensor,
          param,
          %Node{module: AcqdatCore.DataCruncher.Functions.TSMax, id: "tamshh"},
          %Node{module: TSMin, id: "miniden"}
        )

      workflow_id = UUID.uuid1(:hex)
      {:ok, _message} = Workflow.register(workflow_id, graph)
      {_request_id, output} = Workflow.execute(graph_data, workflow_id)
      assert Map.has_key?(output, :print43454)
    end
  end

  defp prepare_graph_data(sensor, param, node1, node2) do
    date_to = Timex.shift(Timex.now(), hours: 1) |> DateTime.truncate(:second)
    date_from = Timex.shift(Timex.now(), hours: -1) |> DateTime.truncate(:second)

    data =
      Dataloader.load_stream(:pds, %{
        sensor_id: sensor.id,
        param_uuid: param.uuid,
        date_from: date_from,
        date_to: date_to
      })

    %{
      node1 => [
        {
          UUID.uuid1(:hex),
          :ts_datasource,
          %Token{data: data, data_type: :query_stream}
        }
      ],
      node2 => [
        {
          UUID.uuid1(:hex),
          :ts_datasource,
          %Token{data: data, data_type: :query_stream}
        }
      ]
    }
  end

  def create_graph(node_from, node_to) do
    Graph.new(type: :directed)
    |> Graph.add_edge(
      node_from,
      node_to,
      label: %EdgeData{from: :tsmax, to: :tsmax}
    )
  end

  defp setup_sensor_with_type(_context) do
    org = insert(:organisation)
    project = insert(:project, org: org)
    sensor_type = setup_sensor_type(org, project)

    sensor =
      insert(:sensor,
        sensor_type: sensor_type,
        org: org,
        project: project,
        name: "vibration_sensor"
      )

    [sensor: sensor, org: org]
  end

  defp setup_sensor_type(org, project) do
    vibration_type_parameters = [
      %{name: "x_axis_vel", data_type: "integer", uuid: UUID.uuid1(:hex)},
      %{name: "z_axis_vel", data_type: "integer", uuid: UUID.uuid1(:hex)},
      %{name: "x_axis_acc", data_type: "integer", uuid: UUID.uuid1(:hex)},
      %{name: "z_axis_acc", data_type: "integer", uuid: UUID.uuid1(:hex)}
    ]

    insert(:sensor_type,
      name: "vibration_sensor_type",
      org: org,
      project: project,
      parameters: vibration_type_parameters
    )
  end
end
