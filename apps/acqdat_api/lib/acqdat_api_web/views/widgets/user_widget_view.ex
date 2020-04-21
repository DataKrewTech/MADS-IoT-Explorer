defmodule AcqdatApiWeb.Widgets.UserView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.Widgets.WidgetView
  alias AcqdatApiWeb.Widgets.UserView

  def render("user_widget.json", %{user_widget: user_widget}) do
    %{
      id: user_widget.id,
      user_id: user_widget.user_id,
      widget_id: user_widget.widget_id,
      widget: render_one(user_widget.widget, WidgetView, "widget.json"),
      user: render_one(user_widget.user, UserView, "user.json")
    }
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email
    }
  end

  def render("index.json", user_widget) do
    %{
      user_widgets: render_many(user_widget.entries, UserView, "user_widget_show.json"),
      page_number: user_widget.page_number,
      page_size: user_widget.page_size,
      total_entries: user_widget.total_entries,
      total_pages: user_widget.total_pages
    }
  end

  def render("user_widget_show.json", %{user: user_widget}) do
    %{
      id: user_widget.id,
      user_id: user_widget.user_id,
      widget_id: user_widget.widget_id,
      widget: render_one(user_widget.widget, WidgetView, "widget_show.json"),
      user: render_one(user_widget.user, UserView, "user.json")
    }
  end
end
