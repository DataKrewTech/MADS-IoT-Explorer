defmodule AcqdatCore.DataCruncher.Functions.TSMin do
  @inports [:ts_datasource]
  @outports [:tsmin]
  @display_name "TimeSeries Min"
  @properties %{}
  @category :function
  @info """
  Function Returns min value for the provided timeseries data stream.

  A timseries stream consist of data in the following format
  ```
  [[DateTime, value]]
  ```
  """

  use Virta.Component
  alias AcqdatCore.Repo

  def run(request_id, inport_args, _outport_args, _instance_pid) do
    data_source = Map.get(inport_args, :ts_datasource)
    result = process_data(data_source)
    {request_id, :reply, %{tsmin: result}}
  end

  defp process_data(%{data_type: :query_stream, data: data}) do
    {:ok, value} =
      Repo.transaction(fn ->
        Enum.reduce(data, 0, fn data, acc ->
          [_, value, _, _] = data
          value = String.to_integer(value)

          if acc < value do
            acc
          else
            value
          end
        end)
      end)

    value
  end

  defp process_data(_) do
    0
  end
end
