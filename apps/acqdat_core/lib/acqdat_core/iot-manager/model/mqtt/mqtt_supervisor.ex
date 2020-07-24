defmodule AcqdatCore.MQTT.Supervisor do

  use DynamicSupervisor

  @doc """
  Start a dynamic supervisor that can hold connection processes.
  The `:name` option can also be given in order to register a supervisor
  name, the supported values are described in the "Name registration"
  section in the `GenServer` module docs.
  """
  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: opts[:name])
  end

  def child_spec(opts) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    DynamicSupervisor.child_spec(opts)
  end

  @doc """
  Start a connection as a child of the `Tortoise.Supervisor`.
  `supervisor` is the name of the supervisor the child should be
  started on, and it defaults to `Tortoise.Supervisor`.
  """
  def start_child(supervisor \\ __MODULE__, opts) do
    spec = {Tortoise.Connection, opts}
    DynamicSupervisor.start_child(supervisor, spec)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
