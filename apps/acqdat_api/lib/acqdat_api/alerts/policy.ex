defmodule AcqdatApi.Alerts.Policy do
  @moduledoc """
  All the helper functions related to policy
  """

  def list_policies() do
    Map.keys(PolicyDefinitionModuleEnum.__enum_map__())
  end
end
