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

  def run(request_id, inport_args, _outport_args, _instance_pid) do
    data_source = Map.get(inport_args, :ts_datasource)
    result = process_data(data_source)
    {request_id, :reply, %{tsmean: result}}
  end

  # [
  #   [~U[2020-07-31 07:31:51Z], "14", "x_axis_vel",
  #    "e66c6a1ad2ff11eab52df218989b265a"],
  #   [~U[2020-07-31 07:31:56Z], "10", "x_axis_vel",
  #    "e66c6a1ad2ff11eab52df218989b265a"],
  #   [~U[2020-07-31 07:32:01Z], "15", "x_axis_vel",
  #    "e66c6a1ad2ff11eab52df218989b265a"],
  #   [~U[2020-07-31 07:32:06Z], "21", "x_axis_vel",
  #    "e66c6a1ad2ff11eab52df218989b265a"],
  #   [~U[2020-07-31 07:32:11Z], "14", "x_axis_vel",
  #    "e66c6a1ad2ff11eab52df218989b265a"],
  #   [~U[2020-07-31 07:32:16Z], "15", "x_axis_vel",
  #    "e66c6a1ad2ff11eab52df218989b265a"],
  #   [~U[2020-07-31 07:32:21Z], "18", "x_axis_vel",
  #    "e66c6a1ad2ff11eab52df218989b265a"],
  #   [~U[2020-07-31 07:32:26Z], "7", "x_axis_vel",
  #    "e66c6a1ad2ff11eab52df218989b265a"],
  #   [~U[2020-07-31 07:32:31Z], "25", "x_axis_vel",
  #    "e66c6a1ad2ff11eab52df218989b265a"],
  #   [~U[2020-07-31 07:32:36Z], "1", "x_axis_vel",
  #    "e66c6a1ad2ff11eab52df218989b265a"]
  # ]
  defp process_data(%{data_type: :query_stream, data: data}) do
    {:ok, {sum, size}} =
      Repo.transaction(fn ->
        sum =
          Enum.reduce(data, 0, fn data, acc ->
            [_, value, _, _] = data
            value = String.to_integer(value)
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
