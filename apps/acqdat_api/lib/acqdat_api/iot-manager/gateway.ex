defmodule AcqdatApi.IotManager.Gateway do
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.IotManager.Gateway
  alias AcqdatApi.IotManager.HTTPCommandHandler

  defdelegate get_all(data, preloads), to: Gateway
  defdelegate delete(gateway), to: Gateway

  def create(params) do
    params = params_extraction(params)
    Gateway.create(params) |> verify_gateway()
  end

  def update(gateway, params) do
    gateway |> Gateway.update(params) |> verify_gateway()
  end

  def load_associations(gateway) do
    Repo.preload(gateway, [:org, :project])
  end

  ############################# private functions ###############3

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

  def setup_command(gateway, _channel = "http", params) do
    %{"commands" => command} = params
    HTTPCommandHandler.put(String.to_integer(gateway.id), command)
  end

  def setup_command(gateway, _channel = "mqtt", params) do
    %{"commands" => command} = params
    Gateway.send_mqtt_command(gateway, command)
  end
end
