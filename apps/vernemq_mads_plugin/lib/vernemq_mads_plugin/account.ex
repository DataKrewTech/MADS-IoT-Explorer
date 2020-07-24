defmodule VernemqMadsPlugin.Account do

  @repo Application.get_env(:vernemq_mads_plugin, :read_repo)
  alias VernemqMadsPlugin.BrokerCredentials
  @error_message "Invalid Credentials"

  @doc """
  Checks if the client trying to connect is a valid one.

  TODO: Create a redis based database for authenticating and authorizing
  all the clients.
  """
  def is_authenticated(uuid, access_token) do
    BrokerCredentials
    |> @repo.get_by(entity_uuid: uuid)
    |> validate(access_token)
  end

  defp validate(nil, _access_token), do: {:error, @error_message}
  defp validate(entity, access_token) do
    if entity.access_token == access_token do
      :ok
    else
      {:error, @error_message}
    end
  end

end
