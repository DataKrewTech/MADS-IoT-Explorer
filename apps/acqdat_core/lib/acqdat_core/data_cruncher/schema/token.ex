defmodule AcqdatCore.DataCruncher.Token do
  @data_types ~w(
    query_stream
    timeseries_univariate
    timeseries_multivariate
    vector_univariate
    vector_multivariate
    integer
   )a

  defstruct ~w(data data_type)a

  def new(opts) when opts == %{} do
    {:error, "expect data and data_type"}
  end

  def new(opts) do
    if valid_data_type?(opts.data_type) do
      {:ok, struct(%__MODULE__{}, opts)}
    else
      {:error, "invalid data type"}
    end
  end

  def valid_data_type?(data_type) do
    Enum.member?(@data_types, data_type)
  end
end
