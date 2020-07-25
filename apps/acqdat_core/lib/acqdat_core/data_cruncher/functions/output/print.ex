defmodule AcqdatCore.DataCruncher.Functions.Print do
 alias AcqdatCore.DataCruncher.Model.TempOutput
  @inports [:ts_datasource]
  @outports [:tsprint]
  @display_name "Print Output"
  @properties %{}
  @category :sync_output
  @info """
  Function Returns the print output value
  """

  use Virta.Component
  alias AcqdatCore.Repo

  def run(request_id, inport_args, _outport_args, _instance_pid) do
    data_source = Map.get(inport_args, :ts_datasource)

    {:ok, result} = process_data(request_id, data_source)
    {request_id, :reply, %{tsprint: result.id}}
  end


  defp process_data(request_id, data_source) do
    params = %{
      workflow_id: request_id,
      data: %{value: data_source}
    }
    {:ok, value} =
      Repo.transaction(fn ->
        {:ok, value} = TempOutput.create(params)
      end)
    value
  end

  defp process_data(_) do
    0
  end
end
