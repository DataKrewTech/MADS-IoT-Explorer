defmodule AcqdatCore.DataCruncher.Functions.TSRange do
  @inports [:ts_datasource]
  @outports [:tsrange]
  # @display_name "TimeSeries Range"
  # @properties %{}
  # @category :function
  # @info """
  # Function Returns Range value for the provided timeseries data stream.

  # A timseries stream consist of data in the following format
  # ```
  # [[DateTime, value]]
  # ```
  # """

  use Virta.Component
  alias AcqdatCore.Repo

  def run(request_id, inport_args, _outport_args, _instance_pid) do
    data_source = Map.get(inport_args, :ts_datasource)
    result = process_data(data_source)
    {request_id, :reply, %{tsrange: result}}
  end

  defp process_data(%{data_type: :query_stream, data: data}) do
    {:ok, value} =
      Repo.transaction(fn ->
        Enum.reduce(data, [], fn data, acc ->
          [timestamp, value, _, _] = data
          acc ++ [[timestamp, value]]
        end)
      end)

    value
  end

  defp process_data(_) do
    0
  end
end
