defmodule AcqdatCore.IotManager.CommandHandler do
  @moduledoc """
  Module to handle commands sent for gateways with channel HTTP.

  Stores commands sent for different gateways in an ets table.
  The data is used when a config response needs to be sent to the
  gateway.
  """

  use GenServer

  def init(arg) do
    :ets.new(:http_command_storage, [
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
    case :ets.lookup(:http_command_storage, key) do
      [] ->
        nil

      [{_key, value}] ->
        value
    end
  end

  def put(key, value) do
    :ets.insert(:http_command_storage, {key, value})
  end

  def delete(key) do
    :ets.delete(:http_command_storage, key)
  end
end
