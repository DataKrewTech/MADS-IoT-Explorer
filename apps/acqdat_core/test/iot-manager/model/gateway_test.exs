defmodule AcqdatCore.Model.IotManager.GatewayTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory

  alias AcqdatCore.Model.IotManager.Gateway

  describe "get_gateways/1" do
    setup do
      project = insert(:project)
      gateway1 = insert(:gateway, parent_type: "Project", parent_id: project.id)
      gateway2 = insert(:gateway, parent_type: "Project", parent_id: project.id)
      sensor1 = insert(:sensor, gateway_id: gateway1.id)
      sensor2 = insert(:sensor, gateway_id: gateway2.id)

      [
        project: project,
        gateway1: gateway1,
        gateway2: gateway2,
        sensor1: sensor1,
        sensor2: sensor2
      ]
    end

    test "fetch heirarchy with gateways", %{
      project: project,
      gateway1: gateway1,
      gateway2: gateway2,
      sensor1: sensor1,
      sensor2: sensor2
    } do
      gateways = Gateway.get_gateways(project.id)
      [resulted_gateway1, resulted_gateway2] = gateways
      [child1] = resulted_gateway1.childs
      [child2] = resulted_gateway2.childs
      assert resulted_gateway1.name == gateway1.name
      assert resulted_gateway2.name == gateway2.name
      assert resulted_gateway1.parent.id == project.id
      assert resulted_gateway2.parent.id == project.id
      assert child1.id == sensor1.id
      assert child2.id == sensor2.id
    end
  end
end
