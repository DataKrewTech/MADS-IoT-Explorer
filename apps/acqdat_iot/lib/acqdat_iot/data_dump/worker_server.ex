defmodule AcqdatIot.DataDump.Worker.Server do
  use GenServer
  alias AcqdatIot.DataDump.Worker.Manager

  def init(params) do
    {:ok, params}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def handle_cast({:data_dump, params}, status) do
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
