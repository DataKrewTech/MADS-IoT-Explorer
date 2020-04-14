defmodule AcqdatApi.Widgets.Widget do
  alias AcqdatCore.Model.Widgets.Widget, as: WidgetModel
  alias AcqdatCore.Repo
  import AcqdatApiWeb.Helpers

  def create(params) do
    %{
      widget_type_id: widget_type_id,
      label: label,
      properties: properties,
      policies: policies,
      category: category,
      default_values: default_values,
      image_url: image_url
    } = params

    verify_widget(
      WidgetModel.create(%{
        widget_type_id: widget_type_id,
        label: label,
        properties: properties,
        policies: policies,
        category: category,
        default_values: default_values,
        image_url: image_url
      })
    )
  end

  defp verify_widget({:ok, widget}) do
    widget = widget |> Repo.preload(:widget_type)

    {:ok,
     %{
       id: widget.id,
       widget_type_id: widget.widget_type_id,
       label: widget.label,
       properties: widget.properties,
       policies: widget.policies,
       category: widget.category,
       default_values: widget.default_values,
       image_url: widget.image_url,
       uuid: widget.uuid,
       widget_type: widget.widget_type
     }}
  end

  defp verify_widget({:error, message}) do
    {:error, %{error: extract_changeset_error(message)}}
  end
end
