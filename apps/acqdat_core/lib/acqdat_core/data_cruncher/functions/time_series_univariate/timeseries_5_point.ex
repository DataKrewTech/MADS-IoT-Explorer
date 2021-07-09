defmodule AcqdatCore.DataCruncher.Functions.TSFivepointSummary do
  @moduledoc """
  Component returns a five point summary of the timeseries univariate
  data provided.

  ###Transactions
  **Input**
  Expects a data stream as input.

  **Output**
  Generates a five point summary of data.
  """
  @inports [:ts_datasource]
  @outports [:summary_5_point]
  # @display_name "5pointSummary"
  # @properties %{}
  # @category :function
  # @info """
  # Returns a five point summary of the timeseries univariate
  # data provided.

  # A timseries stream consist of data in the following format
  # ```
  # [[DateTime, value]]
  # ```

  # """
  use Virta.Component

  @impl true
  # TODO: Need to implement run method of ts_five_point_summary
  def run(request_id, _inport_args, _outport_args, _instance_pid) do
    result = %{}
    {request_id, :reply, %{summary_five_point: result}}
  end
end
