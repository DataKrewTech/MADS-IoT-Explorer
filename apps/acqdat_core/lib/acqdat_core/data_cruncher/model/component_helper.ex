defmodule AcqdatCore.DataCruncher.Model.ComponentHelper do
  @moduledoc """
  Exposes helper functions for dealing with data cruncher components.
  """

  def all_components() do
    components = DataCruncherComponentEnum.__valid_values__()

    components
    |> Stream.filter(&is_atom(&1))
    |> Enum.map(fn module ->
      data = module.component_properties()

      Map.merge(
        data,
        %{
          module: to_string(module)
        }
      )
    end)
  end
end
