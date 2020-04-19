defmodule AcqdatCore.Seed.Widget do
  @moduledoc """
  Holds seeds for initial widgets.
  """


  alias AcqdatCore.Repo
  alias AcqdatCore.Widgets.Schema.WidgetType
  alias AcqdatCore.Widgets.Schema.Vendors.HighCharts
  alias AcqdatCore.Widgets.Schema.Widget, as: WidgetSchema
  alias AcqdatCore.Widgets.Schema.Widget.VisualSettings
  alias AcqdatCore.Widgets.Schema.Widget.DataSettings
  import Tirexs.HTTP
  import Tirexs.Search


  @non_value_types ~w(object list)a
  @highchart_struct %HighCharts{}

  @highchart_key_widget_settings %{
    line: %{
      visual: %{
        chart: [type: %{value: "line"}, backgroundColor: %{}, plotBackgroundColor: %{}],
        title: [text: %{}, align: %{}],
        caption: [text: %{}, align: %{}],
        subtitle: [text: %{}, align: %{}],
        yAxis: [title: [text: %{}]],
      },
      data: %{
        series: %{
          data_type: :list,
          value: %{},
          properties: %{
            name: %{data_type: :string, value: %{}, properties: %{}},
            color: %{data_type: :string, value: %{}, properties: %{}},
          }
        },
        axes: %{
          data_type: :object,
          value: %{},
          properties: %{
            x: %{data_type: :list, value: %{},
              properties: %{multiple: %{data_type: :boolean, value: %{data: false}, properties: %{}}}
            },
            y: %{data_type: :list, value: %{},
              properties: %{multiple: %{data_type: :boolean, value: %{data: true}, properties: %{}}}
            }
          }
        }
      }
    }
  }

  @high_chart_value_settings %{
    line: %{
      visual_setting_values: %{
        title: %{text: "Solar Employment growth by year"},
        caption: %{
           text: "A brief description of the data being stored by
                the chart here."
        },
        subtitle: %{
          text: "Source: thesolarfoundation.com"
        },
        yAxis: %{
          title: %{
            text: "Number of Employees"
          }
        }
      },
      data_settings_values: %{
        series: [
          %{
            name: "Installation",
            data: [43934, 52503, 57177, 69658, 97031, 119931, 137133, 154175]
          }, %{
            name: "Manufacturing",
            data: [24916, 24064, 29742, 29851, 32490, 30282, 38121, 40434]
          }, %{
            name: "Sales & Distribution",
            data: [11744, 17722, 16005, 19771, 20185, 24377, 32147, 39387]
          }, %{
            name: "Project Development",
            data: ["null", "null", 7988, 12169, 15112, 22452, 34400, 34227]
          }, %{
            name: "Other",
            data: [12908, 5948, 8105, 11248, 8989, 11816, 18274, 18111]
          }
        ]
     }
    }
  }

  def seed() do
    widget_type = seed_widget_type()
    seed_widgets(widget_type)
  end

  def seed_widget_type() do
    params = %{
      name: "Highcharts",
      vendor: "Highcharts",
      module: "Elixir.AcqdatCore.Widgets.Schema.Vendors.HighCharts",
      vendor_metadata: %{}
    }

    changeset = WidgetType.changeset(%WidgetType{}, params)
    {:ok, widget_type} = Repo.insert(changeset)
    widget_type
  end

  def seed_widgets(widget_type) do
    @highchart_key_widget_settings
    |> Enum.map(fn {key, widget_settings} ->
      set_widget_data(key, widget_settings, @high_chart_value_settings[key],
        widget_type)
    end)
    |> Enum.each(fn data ->
      Repo.insert!(data)
      create("widgets", data)
    end)
  end

  def set_widget_data(key, widget_settings, data, widget_type) do
    %WidgetSchema{
      label: to_string(key),
      properties: %{},
      uuid: UUID.uuid1(:hex),
      image_url: "https://assets.highcharts.com/images/demo-thumbnails/highcharts/line-basic-default.png",
      category: ["chart", "line"],
      policies: %{},
      widget_type_id: widget_type.id,
      visual_settings: do_settings(widget_settings, :visual),
      data_settings: do_settings(widget_settings, :data),
      default_values: data
    }
  end

  def do_settings(%{visual: settings}, :visual) do
    Enum.map(settings, fn {key, value} ->
      set_keys_from_vendor(key, value, Map.get(@highchart_struct, key))
    end)
  end

  def do_settings(%{data: settings}, :data) do
    Enum.map(settings, fn {key, value} ->
      set_data_keys(key, value)
    end)
  end

  def set_data_keys(key, %{properties: properties} = value) when properties == %{} do
    %DataSettings{
      key: key,
      value: value.value,
      data_type: value.data_type,
      properties: []
    }
  end

  def set_data_keys(key, value) do
    %DataSettings{
      key: key,
      data_type: value.data_type,
      value: value.value,
      properties: Enum.map(value.properties, fn {key, value} ->
        set_data_keys(key, value)
      end)
    }
  end

  def set_keys_from_vendor(key, value, metadata) when is_list(value) do
    %VisualSettings{
      key: key,
      data_type: metadata.data_type,
      user_controlled: metadata.user_controlled,
      value: set_default_or_given_value(key, value, metadata),
      source: %{},
      properties: Enum.map(value,
        fn {child_key, child_value} ->
          set_keys_from_vendor(child_key, child_value, metadata.properties[child_key])
      end)
    }
  end

  def set_keys_from_vendor(key, value, metadata) when is_map(value) do
    %VisualSettings{
      key: key,
      data_type: metadata.data_type,
      user_controlled: metadata.user_controlled,
      source: %{},
      value: set_default_or_given_value(key, value, metadata),
      properties: []
    }
  end

  def set_default_or_given_value(key, value, metadata) do
    if metadata.data_type not in @non_value_types do
      %{
        data:
        if Map.has_key?(value, :value) do
          value.value
        else
          metadata.default_value
        end
      }
    else
      %{}
    end
  end

  def create(type, params) do
    post("#{type}/_doc/#{params.id}",
      id: params.id,
      widget_type_id: params.widget_type_id,
      label: params.label,
      properties: params.properties,
      policies: params.policies,
      category: params.category,
      image_url: params.image_url,
      uuid: params.uuid
      )
  end
end
