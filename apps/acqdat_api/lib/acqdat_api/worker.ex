defmodule AcqdatApi.Worker do
  use GenServer

  def init(arg) do
    :ets.new(:command_storage, [
      :set,
      :public,
      :named_table,
      {:read_concurrency, true},
      {:write_concurrency, true}
    ])

    {:ok, arg}
  end

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def get(key) do
    case :ets.lookup(:command_storage, key) do
      [] ->
        nil

      [{_key, value}] ->
        value
    end
  end

  def put(key, value) do
    :ets.insert(:command_storage, {key, value})
  end
end
