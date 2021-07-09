defmodule AcqdatApi.DataInsights.FactTableSupervisor do
  @moduledoc """
  Supervises the fact table manager and server.
  """

  use Supervisor
  alias AcqdatApi.DataInsights.{FactTableManager, FactTableServer}

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_) do
    children = [
      FactTableManager,
      FactTableServer
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
