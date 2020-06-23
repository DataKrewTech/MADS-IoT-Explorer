defmodule AcqdatIot.DataParser.Worker.Server do
  use GenServer
  alias AcqdatIot.DataParser.Worker.Manager

  def init(params) do
    {:ok, params}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def handle_cast({:data_parser, params}, status) do
    response = data_parser(params)
    {:noreply, response}
  end

  defp data_parser(params) do
    Task.start_link(fn ->
      :poolboy.transaction(
        Manager,
        fn pid -> GenServer.cast(pid, {:data_parser, params}) end
      )
    end)
  end
end
