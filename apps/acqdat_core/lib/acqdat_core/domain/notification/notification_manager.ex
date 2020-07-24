defmodule AcqdatCore.Domain.Notification.Manager do
  alias AcqdatCore.Domain.Notification.Worker

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
      size: 10,
      max_overflow: 10
    ]
  end
end
