defmodule AcqdatCore.IotManager.DataDump.Worker.Server do
  use GenServer
  alias AcqdatCore.IotManager.DataDump.Worker.Manager
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def create(params) do
    GenServer.cast(__MODULE__, {:data_dump, params})
  end

  def init(params) do
    {:ok, params}
  end

  def handle_cast({:data_dump, params}, _status) do
    response = data_dump(params)
    {:noreply, response}
  end

  defp data_dump(params) do
    Task.start_link(fn ->
      :poolboy.transaction(
        Manager,
        fn pid -> GenServer.cast(pid, {:data_dump, params}) end
      )
    end)
  end
end
