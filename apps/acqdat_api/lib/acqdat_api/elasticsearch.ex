defmodule AcqdatApi.ElasticSearch do
  import Tirexs.HTTP
  import Tirexs.Search

  def create(type, params) do
    options = [restart: :transient, max_restarts: 3]

    Task.Supervisor.start_child(
      Datakrew.TaskSupervisor,
      fn ->
        post("#{type}/_doc/#{params.id}",
          id: params.id,
          label: params.label,
          uuid: params.uuid,
          properties: params.properties,
          category: params.category
        )
      end,
      options
    )
  end

  def update(type, params) do
    options = [restart: :transient, max_restarts: 3]

    Task.Supervisor.start_child(
      Datakrew.TaskSupervisor,
      fn ->
        post("#{type}/_update/#{params.id}",
          doc: [
            label: params.label,
            uuid: params.uuid,
            properties: params.properties,
            category: params.category
          ]
        )
      end,
      options
    )
  end

  def delete(type, params) do
    options = [restart: :transient, max_restarts: 3]

    Task.Supervisor.start_child(
      Datakrew.TaskSupervisor,
      fn ->
        delete("#{type}/_doc/#{params}")
      end,
      options
    )
  end

  def search_widget(type, params, retry \\ 3) do
    case do_widget_search(type, params) do
      {:ok, _return_code, hits} ->
        {:ok, hits.hits}

      {:error, _return_code, _hits} ->
        search_widget(type, params, retry - 1)
    end
  end

  def search_user(type, params, retry \\ 3) do
    case do_user_search(type, params) do
      {:ok, _return_code, hits} ->
        {:ok, hits.hits}

      {:error, _return_code, _hits} ->
        search_user(type, params, retry - 1)
    end
  end

  defp do_widget_search(type, params) do
    query =
      search index: "#{type}" do
        query do
          match("label", "#{params}")
        end
      end

    Tirexs.Query.create_resource(query)
  end

  defp do_user_search(type, params) do
    query =
      search index: "#{type}" do
        query do
          match("first_name", "#{params}")
        end
      end

    Tirexs.Query.create_resource(query)
  end

  def user_indexing(page) do
    page_size = String.to_integer(page)
    {:ok, _return_code, hits} = get("/users/_search", size: page_size)
    {:ok, hits.hits}
  end

  def search_widget(_, _, _retry = 0), do: :ignore
  def search_user(_, _, _retry = 0), do: :ignore
end
