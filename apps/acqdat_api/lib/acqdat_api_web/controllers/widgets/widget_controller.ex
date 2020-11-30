defmodule AcqdatApiWeb.Widgets.WidgetController do
  use AcqdatApiWeb, :controller
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.Widgets.Widget
  alias AcqdatApi.Widgets.Widget
  alias AcqdatApi.ElasticSearch
  alias AcqdatCore.Model.Widgets.WidgetType, as: WTModel
  alias AcqdatApi.Image
  alias AcqdatApi.ImageDeletion
  alias AcqdatCore.Model.Widgets.Widget, as: WidgetModel
  alias AcqdatCore.Widgets.Schema.Vendors.HighCharts

  plug :load_widget when action in [:show, :update, :delete]
  plug :load_widget_type when action in [:create]

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, widget} = {:list, WidgetModel.get_all(data, [:widget_type])}

        conn
        |> put_status(200)
        |> render("index.json", widget)

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def fetch_all(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}
        {:list, widgets} = {:list, WidgetModel.get_all_by_classification(data)}

        conn
        |> put_status(200)
        |> render("fetch_all.json", %{data: widgets})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def create(conn, params) do
    case conn.status do
      nil ->
        params = Map.put(params, "image_url", "")

        changeset =
          case is_nil(params["image"]) do
            true ->
              verify_widget_params(params)

            false ->
              params = add_image_url(conn, params)
              verify_widget_params(params)
          end

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, widget}} <- {:create, Widget.create(data)} do
          ElasticSearch.create("widgets", widget)

          conn
          |> put_status(200)
          |> render("widget.json", %{widget: widget})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def show(conn, _params) do
    case conn.status do
      nil ->
        widget =
          conn.assigns.widget
          |> Map.put(
            :visual_prop,
            HighCharts.parse_properties(conn.assigns.widget.visual_settings)
          )
          |> Map.put(:data_prop, HighCharts.parse_properties(conn.assigns.widget.data_settings))

        conn
        |> put_status(200)
        |> render("widget.json", %{widget: widget})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp load_widget(%{params: %{"id" => widget_id}} = conn, _params) do
    {widget_id, _} = Integer.parse(widget_id)

    case WidgetModel.get(widget_id) do
      {:ok, widget} ->
        assign(conn, :widget, widget)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{widget: widget}} = conn
        params = Map.put(params, "image_url", widget.image_url)

        params =
          case is_nil(params["image"]) do
            true ->
              params

            false ->
              add_image_url(conn, params)
          end

        case WidgetModel.update(widget, params) do
          {:ok, widget} ->
            ElasticSearch.update("widgets", widget)

            conn
            |> put_status(200)
            |> render("widget.json", %{widget: widget})

          {:error, widget} ->
            error = extract_changeset_error(widget)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def search_widget(conn, params) do
    with {:ok, hits} <- ElasticSearch.search_widget("widgets", params) do
      conn |> put_status(200) |> render("hits.json", %{hits: hits})
    else
      {:error, message} ->
        conn
        |> put_status(404)
        |> json(%{
          "status_code" => 404,
          "title" => message,
          "detail" => message
        })
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        case WidgetModel.delete(conn.assigns.widget) do
          {:ok, widget} ->
            ElasticSearch.delete("widgets", widget.id)

            Task.async(fn ->
              ImageDeletion.delete_operation(widget.image_url, "widget")
            end)

            conn
            |> put_status(200)
            |> render("widget.json", %{widget: widget})

          {:error, widget} ->
            error = extract_changeset_error(widget)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp load_widget_type(%{params: %{"widget_type_id" => widget_type_id}} = conn, _params) do
    {widget_type_id, _} = Integer.parse(widget_type_id)

    case WTModel.get(widget_type_id) do
      {:ok, widget_type} ->
        assign(conn, :widget_type, widget_type)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end

  defp add_image_url(conn, %{"image" => image} = params) do
    with {:ok, image_name} <- Image.store({image, "widget"}) do
      Map.replace!(params, "image_url", Image.url({image_name, "widget"}))
    else
      {:error, error} -> send_error(conn, 400, error)
    end
  end
end
