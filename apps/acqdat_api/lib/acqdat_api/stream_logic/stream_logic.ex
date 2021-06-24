defmodule AcqdatApi.StreamLogic do
  alias  AcqdatCore.StreamLogic.Model, as: StreamLogic
  import AcqdatApiWeb.Helpers

  defdelegate update(workflow, params), to: StreamLogic
  defdelegate get(params), to: StreamLogic
  defdelegate get_all(params), to: StreamLogic
  defdelegate delete(workflow), to: StreamLogic

  def create(params) do
    params
    |> Map.from_struct()
    |> Map.drop([:_id, :__meta__])
    |> StreamLogic.create()
    |> verify_workflow()
  end


  ############## private functions #####################
  defp verify_workflow({:ok, _workflow} = result), do: result
  defp verify_workflow({:error, workflow}) do
    {:error, %{error: extract_changeset_error(workflow)}}
  end
end
