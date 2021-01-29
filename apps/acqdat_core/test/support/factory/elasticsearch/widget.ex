defmodule AcqdatCore.Factory.ElasticSearch.Widget do
  alias AcqdatCore.ElasticSearch
  import AcqdatCore.Support.Factory
  import Tirexs.HTTP

  def seed_widget(widget) do
    ElasticSearch.create("widgets", widget)
    [widget: widget]
  end

  def delete_index() do
    delete("/widgets")
  end

  def seed_multiple_widget(count) do
    [widget1, widget2, widget3] = insert_list(count, :widget)
    ElasticSearch.create("widgets", widget1)
    ElasticSearch.create("widgets", widget2)
    ElasticSearch.create("widgets", widget3)
    [widget1, widget2, widget3]
  end
end
