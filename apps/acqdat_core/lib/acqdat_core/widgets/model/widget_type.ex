defmodule AcqdatCore.Model.Widgets.WidgetType do
  alias AcqdatCore.Widgets.Schema.WidgetType
  alias AcqdatCore.Model.Widgets.Widget
  alias AcqdatCore.Repo
  import Ecto.Query

  def create(params) do
    changeset = WidgetType.changeset(%WidgetType{}, params)
    Repo.insert(changeset)
  end

  def get(id) when is_integer(id) do
    case Repo.get(WidgetType, id) do
      nil ->
        {:error, "not found"}

      widget_type ->
        {:ok, widget_type}
    end
  end

  def delete(widget_type) do
    Widget.delete_from_elasticsearch(widget_type)
    Repo.delete(widget_type)
  end

  def update(widget_type, params) do
    changeset = WidgetType.update_changeset(widget_type, params)
    Repo.update(changeset)
  end

  def get_all(%{page_size: page_size, page_number: page_number}) do
    WidgetType
    |> order_by(:id)
    |> Repo.paginate(page: page_number, page_size: page_size)
  end
end
