defmodule AcqdatCore.DataCruncher.Functions.TSSort do
  @inports [:ts_datasource]
  @outports [:tssort]
  @display_name "TimeSeries Sort"
  @properties %{}
  @category :function
  @info """
  Function Returns Sorted values for the provided timeseries data stream.

  A timseries stream consist of data in the following format
  ```
  [[DateTime, value]]
  ```
  """

  use Virta.Component
  alias AcqdatCore.Repo

  def run(request_id, inport_args, _outport_args, _instance_pid, _configurations) do
    [workflow_id, type] = String.split(request_id, "_")
    workflow_id = workflow_id |> String.to_integer()
    data_source = Map.get(inport_args, :ts_datasource)
    type = type |> String.to_atom()

    res = data_source |> process_data(type)
    {workflow_id, :reply, %{tssort: res}}
  end

  defp process_data(%{data_type: :query_stream, data: data}, type) do
    {:ok, value} =
      Repo.transaction(fn ->
        Enum.sort_by(data, fn [date, _, _, _] -> date end, {type, DateTime})
      end)

    value
  end

  defp process_data(_, _) do
    0
  end
end
