defmodule AcqdatCore.Domain.Notification.Supervisor do
  use Supervisor

  alias AcqdatCore.Domain.Notification.{Manager, Server}

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_) do
    children = [
      Server,
      Manager
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
