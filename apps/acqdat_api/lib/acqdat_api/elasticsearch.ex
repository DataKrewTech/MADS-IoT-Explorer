defmodule AcqdatApi.ElasticSearch do
  import Tirexs.HTTP

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

    retry(create_function)
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

    retry(update_function)
  end

  def update_users(type, params, org) do
    update = fn ->
      put("#{type}/_doc/#{params.id}?routing=#{org.id}",
        id: params.id,
        email: params.email,
        first_name: params.first_name,
        last_name: params.last_name,
        org_id: params.org_id,
        is_invited: params.is_invited,
        role_id: params.role_id,
        join_field: %{name: "user", parent: org.id}
      )
    end

    retry(update)
  end

  def delete(type, params) do
    delete_function = fn ->
      delete("#{type}/_doc/#{params}")
    end

    retry(delete_function)
  end

  def search_widget(type, params) do
    case do_widget_search(type, params) do
      {:ok, _return_code, hits} ->
        {:ok, hits.hits}

      {:error, _return_code, hits} ->
        {:error, hits}

      :error ->
        {:error, "elasticsearch is not running"}
    end
  end

  def search_user(%{"org_id" => org_id, "label" => label} = params) do
    case do_user_search(org_id, label, params) do
      {:ok, _return_code, hits} ->
        {:ok, hits.hits}

      {:error, _return_code, hits} ->
        {:error, hits}

      :error ->
        {:error, "elasticsearch is not running"}
    end
  end

  def search_projects(%{"org_id" => org_id, "label" => label} = params) do
    case do_project_search(org_id, label, params) do
      {:ok, _return_code, hits} ->
        {:ok, hits.hits}

      {:error, _return_code, hits} ->
        {:error, hits}

      :error ->
        {:error, "elasticsearch is not running"}
    end
  end

  def search_assets(type, %{"label" => label} = params) do
    case do_asset_search(type, label, params) do
      {:ok, _return_code, hits} ->
        {:ok, hits.hits}

      {:error, _return_code, hits} ->
        {:error, hits}

      :error ->
        {:error, "elasticsearch is not running"}
    end
  end

  defp do_widget_search(type, params) do
    query =
      case Map.has_key?(params, "page_size") do
        true ->
          %{"label" => label, "page_size" => page_size, "from" => from} = params
          create_query("label", label, type, page_size, from)

        false ->
          %{"label" => label} = params
          create_query("label", label, type)
      end

    Tirexs.Query.create_resource(query)
  end

  defp do_user_search(org_id, label, params) do
    query =
      case Map.has_key?(params, "page_size") do
        true ->
          %{"page_size" => page_size, "from" => from} = params
          create_user_search_query(org_id, label, page_size, from)

        false ->
          create_user_search_query(org_id, label)
      end

    Tirexs.Query.create_resource(query)
  end

  defp do_project_search(org_id, label, params) do
    query =
      case Map.has_key?(params, "page_size") do
        true ->
          %{"page_size" => page_size, "from" => from} = params
          create_project_search_query(org_id, label, page_size, from)

        false ->
          create_project_search_query(org_id, label)
      end

    Tirexs.Query.create_resource(query)
  end

  defp do_asset_search(type, label, params) do
    query =
      case Map.has_key?(params, "page_size") do
        true ->
          %{"page_size" => page_size, "from" => from} = params
          create_query("name", label, type, page_size, from)

        false ->
          create_query("name", label, type)
      end

    Tirexs.Query.create_resource(query)
  end

  def user_indexing(params) do
    query =
      case Map.has_key?(params, "page_size") do
        true ->
          %{"page_size" => page_size, "from" => from, "org_id" => org_id} = params
          user_indexing_query(org_id, from, page_size)

        false ->
          %{"org_id" => org_id} = params
          user_indexing_query(org_id)
      end

    case Tirexs.Query.create_resource(query) do
      {:ok, _return_code, hits} -> {:ok, hits.hits}
      :error -> {:error, "elasticsearch is not running"}
    end
  end

  def project_indexing(params) do
    query =
      case Map.has_key?(params, "page_size") do
        true ->
          %{"page_size" => page_size, "from" => from, "org_id" => org_id} = params
          project_indexing_query(org_id, from, page_size)

        false ->
          %{"org_id" => org_id} = params
          project_indexing_query(org_id)
      end

    case Tirexs.Query.create_resource(query) do
      {:ok, _return_code, hits} -> {:ok, hits.hits}
      :error -> {:error, "elasticsearch is not running"}
    end
  end

  defp retry(function) do
    GenRetry.retry(function, retries: 3, delay: 10_000)
  end

  defp create_query(field, value, index) do
    [search: [query: [match: ["#{field}": [query: "#{value}", fuzziness: 1]]]], index: "#{index}"]
  end

  defp create_query(field, value, index, size, from) do
    [
      search: [
        query: [match: ["#{field}": [query: "#{value}", fuzziness: 1]]],
        size: size,
        from: from
      ],
      index: "#{index}"
    ]
  end

  defp create_user_search_query(org_id, label) do
    [
      search: [
        query: [
          bool: [
            must: [[parent_id: [type: "user", id: org_id]]],
            filter: [term: ["first_name.keyword": "#{label}"]]
          ]
        ]
      ],
      index: "organisation"
    ]
  end

  defp create_user_search_query(org_id, label, page_size, from) do
    [
      search: [
        query: [
          bool: [
            must: [[parent_id: [type: "user", id: org_id]]],
            filter: [term: ["first_name.keyword": "#{label}"]]
          ]
        ],
        size: page_size,
        from: from
      ],
      index: "organisation"
    ]
  end

  defp create_project_search_query(org_id, label) do
    [
      search: [
        query: [
          bool: [
            must: [[parent_id: [type: "project", id: org_id]]],
            filter: [term: ["name.keyword": "#{label}"]]
          ]
        ]
      ],
      index: "org"
    ]
  end

  defp create_project_search_query(org_id, label, page_size, from) do
    [
      search: [
        query: [
          bool: [
            must: [[parent_id: [type: "project", id: org_id]]],
            filter: [term: ["name.keyword": "#{label}"]]
          ]
        ],
        size: page_size,
        from: from
      ],
      index: "org"
    ]
  end

  defp user_indexing_query(org_id, from, size) do
    [
      search: [
        query: [
          bool: [
            must: [[parent_id: [type: "user", id: org_id]]]
          ]
        ],
        size: size,
        from: from
      ],
      index: "organisation"
    ]
  end

  defp user_indexing_query(org_id) do
    [
      search: [
        query: [
          bool: [
            must: [[parent_id: [type: "user", id: org_id]]]
          ]
        ]
      ],
      index: "organisation"
    ]
  end

  defp project_indexing_query(org_id, from, size) do
    [
      search: [
        query: [
          bool: [
            must: [[parent_id: [type: "project", id: org_id]]]
          ]
        ],
        size: size,
        from: from
      ],
      index: "org"
    ]
  end

  defp project_indexing_query(org_id) do
    [
      search: [
        query: [
          bool: [
            must: [[parent_id: [type: "project", id: org_id]]]
          ]
        ]
      ],
      index: "org"
    ]
  end

  # [ "#{field}": [query: "#{value}", fuzziness: 1]
  def create_user(type, params, org) do
    post("#{type}/_doc/#{params.id}?routing=#{org.id}",
      id: params.id,
      email: params.email,
      first_name: params.first_name,
      last_name: params.last_name,
      org_id: params.org_id,
      is_invited: params.is_invited,
      role_id: params.role_id,
      join_field: %{name: "user", parent: org.id}
    )
  end

  def create_project(type, params, org) do
    post("#{type}/_doc/#{params.id}?routing=#{org.id}",
      id: params.id,
      name: params.name,
      uuid: params.uuid,
      slug: params.slug,
      description: params.description,
      avatar: params.avatar,
      location: params.location,
      archived: params.archived,
      version: params.version,
      start_date: params.start_date,
      creator_id: params.creator_id,
      metadata: params.metadata,
      join_field: %{name: "project", parent: params.org_id}
    )
  end

  def update_project(type, params, org_id) do
    update = fn ->
      post("#{type}/_doc/#{params.id}?routing=#{org_id}",
        id: params.id,
        name: params.name,
        uuid: params.uuid,
        slug: params.slug,
        description: params.description,
        avatar: params.avatar,
        location: params.location,
        archived: params.archived,
        version: params.version,
        start_date: params.start_date,
        creator_id: params.creator_id,
        metadata: params.metadata,
        join_field: %{name: "project", parent: params.org_id}
      )
    end

    retry(update)
  end

  def insert_gateway(type, params) do
    post("#{type}/_doc/#{params.id}?routing=#{params.project_id}",
      id: params.id,
      name: params.name,
      uuid: params.uuid,
      slug: params.slug,
      parent_type: params.parent_type,
      parent_id: params.parent_id,
      description: params.description,
      access_token: params.access_token,
      serializer: params.serializer,
      current_location: params.current_location,
      channel: params.channel,
      image_url: params.image_url,
      static_data: params.static_data,
      streaming_data: params.streaming_data,
      mapped_parameters: params.mapped_parameters,
      timestamp_mapping: params.timestamp_mapping,
      join_field: %{name: "gateway", parent: params.project_id}
    )
  end

  def update_gateway(type, params) do
    update = fn ->
      post("#{type}/_doc/#{params.id}?routing=#{params.project_id}",
        id: params.id,
        name: params.name,
        uuid: params.uuid,
        slug: params.slug,
        parent_type: params.parent_type,
        parent_id: params.parent_id,
        description: params.description,
        access_token: params.access_token,
        serializer: params.serializer,
        current_location: params.current_location,
        channel: params.channel,
        image_url: params.image_url,
        static_data: params.static_data,
        streaming_data: params.streaming_data,
        mapped_parameters: params.mapped_parameters,
        timestamp_mapping: params.timestamp_mapping,
        join_field: %{name: "gateway", parent: params.project_id}
      )
    end

    retry(update)
  end

  def delete_data(type, params) do
    delete("#{type}/_doc/#{params.id}")
  end
end
