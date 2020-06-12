defmodule AcqdatCore.DataCruncher.Domain.WorkflowTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  import AcqdatCore.Test.Support.SensorsData
  alias AcqdatCore.DataCruncher.Functions.TSMax
  alias Virta.Core.Out
  alias Virta.Node
  alias Virta.EdgeData
  alias AcqdatCore.DataCruncher.Domain.Workflow
  alias AcqdatCore.DataCruncher.Model.Dataloader


  describe "register/2" do
    test "registers a workflow" do
      graph = create_graph()
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
    test "registers a workflow", context do
      %{sensor: sensor} = context
      [param | _] = sensor.sensor_type.parameters
      date_to = Timex.shift(Timex.now(), hours: 1) |> DateTime.truncate(:second)
      date_from = Timex.shift(Timex.now(), hours: -1) |> DateTime.truncate(:second)
      result = Dataloader.load(:pds, %{sensor_id: sensor.id,
        param_uuid: param.uuid, date_from: date_from, date_to: date_to})

      require IEx
      IEx.pry
      graph = create_graph()

    end
  end

  def create_graph() do
    Graph.new(type: :directed)
    |> Graph.add_edge(
      %Node{module: TSMax, id: UUID.uuid1(:hex)},
      %Node{module: Out, id: UUID.uuid1(:hex)},
      label: %EdgeData{from: :tsmax, to: :tsmax}
    )
  end

  defp setup_sensor_with_type(_context) do
    org = insert(:organisation)
    project = insert(:project, org: org)
    sensor_type = setup_sensor_type(org, project)
    sensor = insert(:sensor, sensor_type: sensor_type, org: org, project: project,
      name: "vibration_sensor")
    [sensor: sensor, org: org]
  end

  defp setup_sensor_type(org, project) do
    vibration_type_parameters = [
      %{name: "x_axis_vel", data_type: "integer", uuid: UUID.uuid1(:hex)},
      %{name: "z_axis_vel", data_type: "integer", uuid: UUID.uuid1(:hex)},
      %{name: "x_axis_acc", data_type: "integer", uuid: UUID.uuid1(:hex)},
      %{name: "z_axis_acc", data_type: "integer", uuid: UUID.uuid1(:hex)}
    ]

    insert(:sensor_type, name: "vibration_sensor_type", org: org,
      project: project, parameters: vibration_type_parameters)
  end
end
