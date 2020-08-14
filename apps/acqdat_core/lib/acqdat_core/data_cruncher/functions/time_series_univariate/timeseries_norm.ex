defmodule AcqdatCore.DataCruncher.Functions.TSNorm do
  @inports [:ts_datasource]
  @outports [:tsnorm]
  @display_name "TimeSeries Norm"
  @properties %{}
  @category :function
  @info """
  Function Returns norm vector value for the provided timeseries data stream.

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
    {request_id, :reply, %{tsnorm: result}}
  end

  defp process_data(%{data_type: :query_stream, data: data}) do
    {:ok, value} =
      Repo.transaction(fn ->
        sum =
          Enum.reduce(data, 0, fn data, acc ->
            [_, value, _, _] = data
            acc + :math.pow(value, 2)
          end)

        :math.sqrt(sum) |> Float.round(2)
      end)

    value
  end

  defp process_data(_) do
    0
  end
end
