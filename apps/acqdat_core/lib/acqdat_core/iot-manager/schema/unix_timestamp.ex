defmodule AcqdatCore.Schema.IotManager.EctoType.UnixTimestamp do
  @moduledoc """
  Creates a custom type for unix timestamp
  """

  # @behaviour Ecto.Type
  use Ecto.Type
  alias Ecto.Type

  def type, do: :utc_datetime

  def cast(timestamp) when is_integer(timestamp) do
    check_validity(DateTime.from_unix(timestamp))
  end

  def cast(timestamp) when is_binary(timestamp) do
    timestamp = String.to_integer(timestamp)
    check_validity(DateTime.from_unix(timestamp))
  end

  def cast(_), do: :error

  def dump(value) do
    Type.dump(:utc_datetime, value)
  end

  def load(value) do
    {:ok, date} = Type.load(:utc_datetime, value)
    {:ok, DateTime.to_unix(date)}
  end

  ########################## private functions ##################
  defp check_validity({:ok, timestamp}) do
    {:ok, timestamp}
  end

  defp check_validity({:error, _message}) do
    {:error, message: "invalid unix timestamp"}
  end
end
