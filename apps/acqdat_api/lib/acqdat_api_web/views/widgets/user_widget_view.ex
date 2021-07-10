defmodule AcqdatApiWeb.Widgets.UserWidgetView do
  use AcqdatApiWeb, :view
  alias AcqdatApiWeb.Widgets.WidgetView
  alias AcqdatApiWeb.Widgets.UserWidgetView

  def render("user.json", %{user_widget: %{user_credentials: user_cred} = user}) do
    %{
      id: user.id,
      first_name: user_cred.first_name,
      last_name: user_cred.last_name,
      email: user_cred.email
    }
  end

  def render("index.json", user_widget) do
    %{
      user_widgets: render_many(user_widget.entries, UserWidgetView, "user_widget_show.json"),
      page_number: user_widget.page_number,
      page_size: user_widget.page_size,
      total_entries: user_widget.total_entries,
      total_pages: user_widget.total_pages
    }
  end

  def render("user_widget_show.json", %{user_widget: user_widget}) do
    %{
      id: user_widget.id,
      user_id: user_widget.user_id,
      widget_id: user_widget.widget_id,
      widget: render_one(user_widget.widget, WidgetView, "widget_show.json"),
      user: render_one(user_widget.user, UserWidgetView, "user.json")
    }
  end
end
