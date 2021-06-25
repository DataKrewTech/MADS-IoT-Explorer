defmodule AcqdatApi.Alerts.Policy do
  @moduledoc """
  All the helper functions related to policy
  """

  def list_policies() do
    Enum.reduce(PolicyDefinitionModuleEnum.__enum_map__(), [], fn {key, _}, acc ->
      acc ++ [key]
    end)
  end
end
