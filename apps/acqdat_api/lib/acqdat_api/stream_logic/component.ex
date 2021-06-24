defmodule AcqdatApi.StreamLogic.Component do
  alias AcqdatCore.StreamLogic.Model.Helpers

  defdelegate components, to: Helpers
end
