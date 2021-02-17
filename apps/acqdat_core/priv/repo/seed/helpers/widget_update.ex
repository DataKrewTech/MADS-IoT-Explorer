defmodule AcqdatCore.Seed.Helpers.HighchartsUpdateHelpers do

  defmacro __using__(_) do
    quote do
      Module.register_attribute(__MODULE__, :highchart_key_widget_settings, persist: true)
      @before_compile unquote(__MODULE__)
    end
  end


  defmacro __before_compile__(_env) do
    module = __CALLER__.module
    Module.get_attribute(module, :highchart_key_widget_settings)

    quote do
      alias AcqdatCore.Repo
      alias AcqdatCore.Seed.Helpers.WidgetHelpers
      alias AcqdatCore.Widgets.Schema.Widget, as: WidgetSchema
      alias AcqdatCore.Widgets.Schema.Vendors.HighCharts

      def update_visual_settings(label, key) do
        widget = Repo.get_by(WidgetSchema, %{label: label})
        widget_settings = @highchart_key_widget_settings[key]
        visual_settings = WidgetHelpers.do_update_settings(widget_settings, :visual, %HighCharts{})
        changeset = WidgetSchema.update_changeset(widget, %{visual_settings: visual_settings})
        Repo.update!(changeset)
      end
    end
  end

end
