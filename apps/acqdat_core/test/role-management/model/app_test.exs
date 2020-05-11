defmodule AcqdatCore.Model.RoleManagement.AppTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.RoleManagement.App, as: AppModel

  describe "get_all" do
    test "returns apps data" do
      insert(:app)
      insert(:app)

      params = %{page_size: 10, page_number: 1}
      result = AppModel.get_all(params)

      assert not is_nil(result)
      assert result.total_entries == 2
    end

    test "returns error not found, if apps are not present" do
      params = %{page_size: 10, page_number: 1}
      result = AppModel.get_all(params)

      assert result.entries == []
      assert result.total_entries == 0
    end
  end
end
