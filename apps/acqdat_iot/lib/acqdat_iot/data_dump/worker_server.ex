defmodule AcqdatIot.DataDump.Worker.Server do
  use GenServer
  alias AcqdatIot.DataDump.Worker.Manager
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def create(params) do
    params = params_extraction(params)
    GenServer.cast(__MODULE__, {:data_dump, params})
  end

  defp params_extraction(params) do
    Map.from_struct(params)
    |> Map.drop([:_id, :__meta__])
  end

  def init(params) do
    {:ok, params}
  end

  def handle_cast({:data_dump, params}, _status) do
    IO.inspect(params)
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
