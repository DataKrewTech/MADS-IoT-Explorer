defmodule AcqdatCore.StreamLogic.Model.Helpers do
  @moduledoc """
  Helper methods for streamlogic.
  """

  @doc """
  Returns a list of all the function nodes in streamlogic.

  Every element of the list containes a detailed information about the
  function node.

  Every node has the following information
  `display_name`, `info`, `category`, `inports`, `outports` and `properties`.

  The `properties` key stores information about the keys which should be set
  for a particular node by the user.
  Every key in the `property` map has the following value.
  %{
    type:
    default_value:
    source: (optional)
  }
  This is mainly used for rendering the frontend for properties of a node.
  The `type` keyword is used for identifying the UI element to be used for
  rendering the key.
  A `type` can be one of the following:
  - `input-multiple`
  - `input-text`
  - `input-radio`
  - `input-checkbox`
  - `select`
  - `multi-select`
  - `js-script`
  - `html-input`
  """
  @spec components() :: [map]
  def components() do
    list = StreamLogicFunctionEnum.__enum_map__()

    list
    |> Stream.map(fn {key, _value} ->
      key
    end)
    |> Enum.map(fn module ->
      add_module_details(module)
    end)
  end

  # Creates a map containing all the module information for a function node.
  # Function nodes are defined in the function folder. Nodes are of different
  # types such as action, filter or enrichment.
  defp add_module_details(module) do
    module_details = module.component_properties()
    module = to_string(module)
    Map.put(module_details, :module, module)
  end
end
