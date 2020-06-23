defmodule AcqdatIot.DataParser.Worker.Manager do
  alias AcqdatIot.DataParser.Worker

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
      size: 1000,
      max_overflow: 500
    ]
  end
end
