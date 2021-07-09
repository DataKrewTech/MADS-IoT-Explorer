defmodule AcqdatCore.Alerts.Supervisor do
  use Supervisor

  alias AcqdatCore.Alerts.Server

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_) do
    children = [
      Server
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
