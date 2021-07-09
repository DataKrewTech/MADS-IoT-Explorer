defmodule AcqdatCore.IotManager.DataParser.Worker do
  use GenServer
  alias AcqdatCore.IotManager.DataParser

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_cast({:data_parser, params}, _state) do
    response = DataParser.start_parsing(params)
    {:noreply, response}
  end
end
