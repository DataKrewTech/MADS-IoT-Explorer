defmodule AcqdatApi.ElasticSearch do
  import Tirexs.HTTP
  import Tirexs.Search

  def create(type, params) do
    create_function = fn ->
      post("#{type}/_doc/#{params.id}",
        id: params.id,
        label: params.label,
        uuid: params.uuid,
        properties: params.properties,
        category: params.category
      )
    end

    GenRetry.retry(create_function, retries: 3, delay: 10_000)
  end

  def update(type, params) do
    update_function = fn ->
      post("#{type}/_update/#{params.id}",
        doc: [
          label: params.label,
          uuid: params.uuid,
          properties: params.properties,
          category: params.category
        ]
      )
    end

    GenRetry.retry(update_function, retries: 3, delay: 10_000)
  end

  def delete(type, params) do
    delete_function = fn ->
      delete("#{type}/_doc/#{params}")
    end

    GenRetry.retry(delete_function, retries: 3, delay: 10_000)
  end

  def search_widget(params, retry \\ 3) do
    case do_search(params) do
      {:ok, _return_code, hits} ->
        {:ok, hits.hits}

      {:error, _return_code, _hits} ->
        search_widget(params, retry - 1)
    end
  end

  defp do_search(params) do
    query =
      search index: "widgets" do
        query do
          match("label", "#{params}")
        end
      end

    Tirexs.Query.create_resource(query)
  end

  def search_widget(_, _retry = 0), do: :ignore
end
