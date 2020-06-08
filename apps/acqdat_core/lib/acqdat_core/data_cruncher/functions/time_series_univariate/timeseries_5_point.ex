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
  @inports [:datasource]
  @outports [:tsmax]

  alias AcqdatCore.Repo
  use Virta.Component

  def run(request_id, inport_args, _outport_args, _instance_pid) do
  end
end
