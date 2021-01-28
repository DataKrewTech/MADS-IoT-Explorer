defmodule AcqdatApi.Helper.Redis do
  @moduledoc """
  Helper module for Recent Dashboard store in Redis.
  """

  @name :redix_dasbhoard
  @redis_port Application.get_env(:acqdat_api, :redis_port)

  def child() do
    {Redix, {@redis_port, name: @name}}
  end

  def get_dashboard_ids(user_id) do
    case Redix.command(@name, ["GET", user_id]) do
      {:ok, nil} -> {:ok, []}
      {:ok, ids} -> {:ok, ids |> to_charlist}
      {:error, _} -> {:error, "Redis instance not running"}
    end
  end

  def insert_dashboard(dashboard, user_id) do
    case Redix.command(@name, ["GET", user_id]) do
      {:ok, nil} -> insert_org(user_id, dashboard.id)
      {:ok, ids} -> update_org(user_id, dashboard.id, ids)
      {:error, _} -> {:error, "Redis instance not running"}
    end
  end

  defp insert_org(user_id, id) do
    Redix.command(@name, ["SET", user_id, [id]])
  end

  defp update_org(user_id, id, ids) do
    ids = ids |> to_charlist

    ids =
      case length(ids) do
        5 ->
          case Enum.member?(ids, id) do
            true ->
              ids

            false ->
              last_value = Enum.at(ids, 4)
              [id] ++ (ids -- [last_value])
          end

        _ ->
          case Enum.member?(ids, id) do
            true -> ids
            false -> [id] ++ ids
          end
      end

    Redix.command(@name, ["SET", user_id, ids])
  end
end
