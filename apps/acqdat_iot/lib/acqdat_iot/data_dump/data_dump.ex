defmodule AcqdatIot.DataDump do
  alias AcqdatCore.Model.EntityManagement.GatewayDataDump, as: GDDModel
  alias AcqdatIot.DataDump.Worker.Server
  alias AcqdatApi.Worker

  def create(params) do
    params = params_extraction(params)
    {:ok, pid} = GenServer.start_link(Server, params)
    GenServer.cast(pid, {:data_dump, params})

    case Worker.get(params.gateway_id) do
      command ->
        Worker.delete(params.gateway_id)
        {:ok, command}

      nil ->
        {:error, "command not found"}
    end
  end

  defp params_extraction(params) do
    Map.from_struct(params)
    |> Map.drop([:_id, :__meta__])
  end
end
