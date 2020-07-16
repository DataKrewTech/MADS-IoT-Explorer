defmodule AcqdatIot.DataParser.Worker do
  use GenServer
  alias AcqdatIot.DataParser

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_args) do
    {:ok, nil}
  end

  def handle_cast({:data_parser, params}, _state) do
    response = DataParser.start_parsing(params)
    {:noreply, response}
  end
end
