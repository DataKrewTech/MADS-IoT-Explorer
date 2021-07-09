defmodule AcqdatApi.ExtractRoutesSupervisor do
  use Supervisor

  alias AcqdatApi.ExtractRoutes

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_) do
    children = [
      ExtractRoutes
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
