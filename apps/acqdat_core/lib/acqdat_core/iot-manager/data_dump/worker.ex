defmodule AcqdatCore.IotManager.DataDump.Worker do
  use GenServer
  alias AcqdatCore.IotManager.DataParser.Worker.Server
  alias AcqdatCore.Model.IotManager.GatewayDataDump, as: GDDModel
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_args) do
    {:ok, nil}
  end

  def handle_cast({:data_dump, params}, _state) do
    response = verify_data_dump(GDDModel.create(params))
    {:noreply, response}
  end

  defp verify_data_dump({:ok, data}) do
    GenServer.cast(Server, {:data_parser, data})
    {:ok, data}
  end

  defp verify_data_dump({:error, error}) do
    error = parse_error(error)
    {:error, error}
  end

  defp parse_error(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  defp parse_error(data) do
    data
  end

end
