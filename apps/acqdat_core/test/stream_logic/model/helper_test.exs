defmodule AcqdatCore.StreamLogic.Model.HelpersTest do
  use ExUnit.Case, async: true
  alias AcqdatCore.StreamLogic.Model.Helpers

  describe "all_functions: " do
    test "returns functions with details" do
      function_list = Helpers.components()

      assert length(function_list) == 14
      assert Enum.all?(function_list, fn module_detail ->
        Map.has_key?(module_detail, :inports) and
        Map.has_key?(module_detail, :outports) and
        Map.has_key?(module_detail, :display_name) and
        Map.has_key?(module_detail, :category) and
        Map.has_key?(module_detail, :info) and
        Map.has_key?(module_detail, :properties) and
        Map.has_key?(module_detail, :module)
      end)
    end
  end
end
