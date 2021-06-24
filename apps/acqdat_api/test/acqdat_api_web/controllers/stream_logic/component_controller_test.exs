defmodule AcqdatApiWeb.StreamLogic.ComponentControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "components: " do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      [org: org]
    end

    test "returns all the components", context do
      %{conn: conn, org: org} = context
      conn = get(conn, Routes.stream_logic_component_path(conn, :components, org.id))

      result = conn |> json_response(200)
      assert length(result["components"]) == 14
    end
  end
end
