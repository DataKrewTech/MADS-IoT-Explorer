defmodule AcqdatCore.Seed.DataFeeder.Widget do
  alias AcqdatCore.Widgets.Schema.Widget
  alias AcqdatCore.Repo
  import Tirexs.HTTP

  def seed_data!() do
    widgets = Repo.all(Widget)
    Enum.each(widgets, fn widget ->
      insert_widget("widgets", widget)
    end)
  end

  defp insert_widget(type, params) do
    post("#{type}/_doc/#{params.id}",
        id: params.id,
        label: params.label,
        uuid: params.uuid,
        properties: params.properties,
        category: params.category,
        widget_type_id: params.widget_type_id
      )
  end
end
