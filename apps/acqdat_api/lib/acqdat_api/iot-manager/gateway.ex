defmodule AcqdatApi.IotManager.Gateway do
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.IotManager.Gateway

  defdelegate get_all(data, preloads), to: Gateway
  defdelegate delete(gateway), to: Gateway
  defdelegate update(gateway, params), to: Gateway

  def create(params) do
    params = params_extraction(params)
    Gateway.create(params) |> verify_gateway()
  end

  defp verify_gateway({:ok, gateway}) do
    gateway = gateway |> Repo.preload([:org, :project])
    {:ok, gateway}
  end

  defp verify_gateway({:error, gateway}) do
    {:error, %{error: extract_changeset_error(gateway)}}
  end

  defp params_extraction(params) do
    Map.from_struct(params)
    |> Map.drop([:_id, :__meta__])
  end

  def store_data(%{"gateway_id" => gateway_id, "commands" => command}) do
    AcqdatApi.Worker.put(String.to_integer(gateway_id), command)
  end

  def follow_mqtt_path() do
    require IEx
    IEx.pry()
  end
end
