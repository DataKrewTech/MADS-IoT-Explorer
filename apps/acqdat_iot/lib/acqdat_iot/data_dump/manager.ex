defmodule AcqdatIot.DataDump.Worker.Manager do
  alias AcqdatIot.DataDump.Worker

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
