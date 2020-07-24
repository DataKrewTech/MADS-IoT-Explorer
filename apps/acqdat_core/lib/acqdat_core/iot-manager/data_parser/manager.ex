defmodule AcqdatCore.IotManager.DataParser.Worker.Manager do
  alias AcqdatCore.IotManager.DataParser.Worker

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
      worker_module: Worker,
      size: 50,
      max_overflow: 30
    ]
  end
end
