defmodule AcqdatIot.DataParser.Supervisor do
  use Supervisor

  alias AcqdatIot.DataParser.Worker.{Server, Manager}

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = [
      Server,
      Manager
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
