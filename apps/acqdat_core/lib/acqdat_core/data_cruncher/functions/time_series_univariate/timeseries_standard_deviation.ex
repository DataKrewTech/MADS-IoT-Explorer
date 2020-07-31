defmodule AcqdatCore.DataCruncher.Functions.TSStandardDeviation do
  @inports [:ts_datasource]
  @outports [:tsstandartdeviation]
  @display_name "TimeSeries Standard Deviation"
  @properties %{}
  @category :function
  @info """
  Function Returns standard deviation value for the provided timeseries data stream.

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
    {request_id, :reply, %{tsvariance: result}}
  end

  defp process_data(%{data_type: :query_stream, data: data}) do
    {:ok, {sum_powered_deviations, size}} =
      Repo.transaction(fn ->
        sum =
          Enum.reduce(data, 0, fn data, acc ->
            [_, value, _, _] = data
            value = String.to_integer(value)
            acc + value
          end)

        len = Enum.count(data)

        mean = (sum / len) |> Float.round(2)

        {sum_powered_deviations(data, mean), len}
      end)

    :math.sqrt(sum_powered_deviations / size) |> Float.round(2)
  end

  defp process_data(_) do
    0
  end

  defp sum_powered_deviations(data, mean) do
    Enum.reduce(data, 0, fn data, acc ->
      [_, value, _, _] = data
      value = String.to_integer(value)
      acc + :math.pow(value - mean, 2)
    end)
  end
end
