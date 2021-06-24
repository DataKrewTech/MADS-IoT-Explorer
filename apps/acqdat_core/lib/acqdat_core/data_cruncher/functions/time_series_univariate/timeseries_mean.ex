defmodule AcqdatCore.DataCruncher.Functions.TSMean do
  @inports [:ts_datasource]
  @outports [:tsmean]
  @display_name "TimeSeries Mean"
  @properties %{}
  @category :function
  @info """
  Function Returns mean value for the provided timeseries data stream.

  A timseries stream consist of data in the following format
  ```
  [[DateTime, value]]
  ```
  """

  use Virta.Component
  alias AcqdatCore.Repo

  def run(request_id, inport_args, _outport_args, _instance_pid, _configurations) do
    data_source = Map.get(inport_args, :ts_datasource)
    result = process_data(data_source)
    {request_id, :reply, %{tsmean: result}}
  end

  defp process_data(%{data_type: :query_stream, data: data}) do
    {:ok, {sum, size}} =
      Repo.transaction(fn ->
        sum =
          Enum.reduce(data, 0, fn data, acc ->
            [_, value, _, _] = data
            acc + value
          end)

        len = Enum.count(data)
        {sum, len}
      end)

    (sum / size) |> Float.round(2)
  end

  defp process_data(_) do
    0
  end
end
