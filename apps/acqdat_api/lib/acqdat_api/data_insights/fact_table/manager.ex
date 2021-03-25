defmodule AcqdatApi.DataInsights.FactTableManager do
  @moduledoc """
  FactTableManager manages the worker pool that will handle the incoming fact
  table requests.
  """
  alias AcqdatApi.DataInsights.FactTableWorker

  def child_spec(_) do
    :poolboy.child_spec(
      __MODULE__,
      poolboy_config(),
      []
    )
  end

  defp poolboy_config() do
    [
      name: {:local, __MODULE__},
      worker_module: FactTableWorker,
      size: 30,
      max_overflow: 10
    ]
  end
end
