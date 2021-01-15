defmodule AcqdatApi.Helper.Redis do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> start_redis() end, name: __MODULE__)
  end

  defp start_redis() do
    Redix.start_link(System.get_env("REDIS_PORT"), name: :redix)
  end

  def get_dashboard_ids(org_id) do
    {:ok, pid} = Redix.start_link()

    case Redix.command(pid, ["GET", org_id]) do
      {:ok, nil} -> {:ok, []}
      {:ok, ids} -> {:ok, ids |> to_charlist}
      {:error, _} -> {:error, "Redis instance not running"}
    end
  end

  def insert_dashboard(dashboard) do
    {:ok, pid} = Redix.start_link()

    case Redix.command(pid, ["GET", dashboard.org_id]) do
      {:ok, nil} -> insert_org(dashboard.org_id, dashboard.id, pid)
      {:ok, ids} -> update_org(dashboard.org_id, dashboard.id, pid, ids)
      {:error, _} -> {:error, "Redis instance not running"}
    end
  end

  defp insert_org(org_id, id, pid) do
    Redix.command(pid, ["SET", org_id, [id]])
  end

  defp update_org(org_id, id, pid, ids) do
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

    Redix.command(pid, ["SET", org_id, ids])
  end
end
