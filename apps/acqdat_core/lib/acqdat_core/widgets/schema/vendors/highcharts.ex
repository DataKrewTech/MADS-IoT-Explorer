defmodule AcqdatCore.Widgets.Schema.Vendors.HighCharts do
  alias AcqdatCore.Model.EntityManagement.SensorData

  @moduledoc """
    Embedded Schema of the settings of the widget with it keys and subkeys
  """
  @data_types ~w(string color object list integer boolean)a

  defstruct chart: %{
              data_type: :object,
              user_controlled: false,
              properties: %{
                type: %{data_type: :string, default_value: "", user_controlled: false},
                backgroundColor: %{
                  data_type: :color,
                  default_value: "#ffffff",
                  user_controlled: true
                },
                borderColor: %{data_type: :color, default_value: "#335cad", user_controlled: true},
                plotBackgroundColor: %{
                  data_type: :color,
                  default_value: "#ffffff",
                  user_controlled: true
                },
                height: %{data_type: :string, default_value: "", user_controlled: false},
                width: %{data_type: :string, default_value: "", user_controlled: false}
              }
            },
            rangeSelector: %{
              data_type: :object,
              user_controlled: false,
              properties: %{
                selected: %{data_type: :integer, default_value: 1, user_controlled: true}
              }
            },
            caption: %{
              data_type: :object,
              user_controlled: false,
              properties: %{
                text: %{data_type: :string, default_value: "", user_controlled: true},
                align: %{data_type: :string, default_value: "left", user_controlled: true}
              }
            },
            color_axis: %{
              data_type: :list,
              user_controlled: false,
              properties: %{
                min: %{data_type: :integer, default_value: 0, user_controlled: false},
                max: %{data_type: :integer, default_value: 0, user_controlled: false},
                layout: %{data_type: :string, default_value: "horizontal", user_controlled: false}
              }
            },
            credits: %{
              data_type: :object,
              user_controlled: false,
              properties: %{
                enabled: %{data_type: :boolean, default_value: false, user_controlled: false}
              }
            },
            exporting: %{
              data_type: :object,
              user_controlled: false,
              properties: %{
                enabled: %{data_type: :boolean, default_value: false, user_controlled: false}
              }
            },
            legend: %{
              data_type: :object,
              user_controlled: false,
              properties: %{
                enabled: %{data_type: :boolean, default_value: false, user_controlled: false},
                layout: %{data_type: :string, default_value: "right", user_controlled: true},
                align: %{data_type: :string, default_value: "right", user_controlled: true},
                verticalAlign: %{
                  data_type: :string,
                  default_value: "middle",
                  user_controlled: true
                }
              }
            },
            navigation: %{
              data_type: :object,
              user_controlled: false,
              properties: %{
                menuStyle: %{data_type: :object, default_value: %{}, user_controlled: false},
                menuItemHoverStyle: %{
                  data_type: :object,
                  default_value: %{},
                  user_controlled: false
                }
              }
            },
            pane: %{
              data_type: :object,
              user_controlled: false,
              properties: %{
                center: %{data_type: :list, default_value: [], user_controlled: true},
                size: %{data_type: :string, default_value: "85%", user_controlled: false},
                background: %{
                  data_type: :list,
                  user_controlled: false,
                  properties: %{
                    backgroundColor: %{
                      data_type: :color,
                      default_value:
                        "{ linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 }, stops: [[0, #ffffff], [1, #e6e6e6]]}",
                      user_controlled: false
                    },
                    borderColor: %{
                      data_type: :color,
                      default_value: "#cccccc",
                      user_controlled: false
                    },
                    innerRadius: %{data_type: :string, default_value: "0", user_controlled: false},
                    outerRadius: %{data_type: :string, default_value: "", user_controlled: false},
                    shape: %{data_type: :string, default_value: "", user_controlled: false}
                  }
                },
                startAngle: %{data_type: :integer, default_value: 0, user_controlled: true},
                endAngle: %{data_type: :integer, default_value: 0, user_controlled: true}
              }
            },
            plotOptions: %{
              data_type: :object,
              user_controlled: false
            },
            responsive: %{
              user_controlled: false,
              data_type: :object,
              rules: %{
                data_type: :list,
                properties: %{
                  condition: %{
                    data_type: :object,
                    maxHeight: %{data_type: :integer, default_value: 0, user_controlled: false},
                    maxWidth: %{data_type: :integer, default_value: 0, user_controlled: false},
                    minHeight: %{data_type: :integer, default_value: 0, user_controlled: false},
                    minWidth: %{data_type: :integer, default_value: 0, user_controlled: false}
                  }
                }
              }
            },
            subtitle: %{
              data_type: :object,
              user_controlled: false,
              properties: %{
                text: %{data_type: :string, default_value: "", user_controlled: true},
                style: %{data_type: :object, default_value: %{}, user_controlled: false},
                align: %{data_type: :string, default_value: "center", user_controlled: true}
              }
            },
            time: %{
              data_type: :object,
              user_controlled: false,
              properties: %{
                timezone: %{data_type: :string, default_value: "", user_controlled: false},
                useUTC: %{data_type: :boolean, default_value: true, user_controlled: false}
              }
            },
            title: %{
              data_type: :object,
              user_controlled: false,
              properties: %{
                text: %{data_type: :string, default_value: "", user_controlled: true},
                style: %{data_type: :object, default_value: %{}, user_controlled: false},
                align: %{data_type: :string, default_value: "center", user_controlled: true}
              }
            },
            tooltip: %{
              data_type: :object,
              user_controlled: false,
              properties: %{
                backgroundColor: %{data_type: :color, default_value: "", user_controlled: true},
                valuePrefix: %{data_type: :string, default_value: "", user_controlled: true},
                valueSuffix: %{data_type: :string, default_value: "", user_controlled: true},
                pointFormat: %{
                  data_type: :string,
                  default_value: "center",
                  user_controlled: false
                }
              }
            },
            xAxis: %{
              data_type: :list,
              user_controlled: false,
              properties: %{
                alignTricks: %{data_type: :boolean, default_value: true, user_controlled: false},
                alternateGridColor: %{data_type: :color, default_value: "", user_controlled: true},
                dateTimeLabelFormats: %{
                  data_type: :object,
                  default_value: %{},
                  user_controlled: false
                },
                labels: %{data_type: :object, default_value: %{}, user_controlled: false},
                title: %{
                  data_type: :object,
                  default_value: %{},
                  user_controlled: false,
                  properties: %{
                    text: %{data_type: :string, default_value: "", user_controlled: true}
                  }
                },
                visible: %{data_type: :boolean, default_value: true, user_controlled: false},
                type: %{data_type: :string, default_value: true, user_controlled: true},
                min: %{data_type: :integer, default_value: "null", user_controlled: true},
                max: %{data_type: :integer, default_value: "null", user_controlled: true},
                plotBands: %{data_type: :list, default_value: %{}, user_controlled: true}
              }
            },
            yAxis: %{
              data_type: :list,
              user_controlled: false,
              properties: %{
                alignTricks: %{data_type: :boolean, default_value: true, user_controlled: false},
                alternateGridColor: %{data_type: :color, default_value: "", user_controlled: true},
                dateTimeLabelFormats: %{
                  data_type: :object,
                  default_value: %{},
                  user_controlled: false
                },
                labels: %{
                  data_type: :object,
                  user_controlled: false,
                  properties: %{
                    step: %{data_type: :integer, default_value: 2, user_controlled: true},
                    rotation: %{data_type: :string, default_value: "auto", user_controlled: true}
                  }
                },
                title: %{
                  data_type: :object,
                  default_value: %{},
                  user_controlled: false,
                  properties: %{
                    text: %{data_type: :string, default_value: "", user_controlled: true},
                    y: %{data_type: :integer, default_value: 2, user_controlled: true}
                  }
                },
                visible: %{data_type: :boolean, default_value: true, user_controlled: false},
                type: %{data_type: :string, default_value: true, user_controlled: true},
                min: %{data_type: :integer, default_value: 0, user_controlled: true},
                max: %{data_type: :integer, default_value: 200, user_controlled: true},
                tickPixelInterval: %{
                  data_type: :integer,
                  default_value: 30,
                  user_controlled: true
                },
                plotBands: %{
                  data_type: :list,
                  user_controlled: true,
                  properties: %{
                    color: %{
                      data_type: :color,
                      default_value: "#cccccc",
                      user_controlled: false
                    },
                    from: %{
                      data_type: :integer,
                      default_value: 0,
                      user_controlled: false
                    },
                    to: %{
                      data_type: :integer,
                      default_value: 100,
                      user_controlled: false
                    }
                  }
                }
              }
            },
            zAxis: %{
              data_type: :list,
              user_controlled: false,
              properties: %{
                alignTricks: %{data_type: :boolean, default_value: true, user_controlled: false},
                alternateGridColor: %{data_type: :color, default_value: "", user_controlled: true},
                dateTimeLabelFormats: %{
                  data_type: :object,
                  default_value: %{},
                  user_controlled: false
                },
                labels: %{data_type: :object, default_value: %{}, user_controlled: false},
                title: %{
                  data_type: :object,
                  default_value: %{},
                  user_controlled: false,
                  properties: %{
                    text: %{data_type: :string, default_value: "", user_controlled: true}
                  }
                },
                visible: %{data_type: :boolean, default_value: true, user_controlled: false},
                type: %{data_type: :string, default_value: true, user_controlled: true},
                min: %{data_type: :integer, default_value: "null", user_controlled: true},
                max: %{data_type: :integer, default_value: "null", user_controlled: true},
                plotBands: %{data_type: :list, default_value: %{}, user_controlled: true}
              }
            },
            series: %{
              data_type: :list,
              user_defined: false,
              properties: %{}
            }

  @doc """
  Takes data in the form of axes and series and arranges the data
  in the format specified by highcharts.

  The `axes` map has data by axes name and it's values.
  ## Example
    %{
      x: [[1,2,3,4]],
      y: [[1,2,3,4],
          [101, 102, 103, 104]
         ]
    }

  A `series` refers to a set of combination of axes data.
  From above example a series would consist of [x, y[0]], [x, y[1]].
  A series usually is made of horizontal axes data combined with a set
  of values from any other axes.

  So for two different set of values in y there are two series.
  The series is a list of visual settings for the above data.

  ## Example
    series: [
      {name: "Manufacturing", color: "#ffffff" }  # for series [x, y[0]]
      {name: "Installation", color: "#dacbde" }  # for series [x, y[1]]
    ]

  Highcharts stores data and it's related information in different format
  for different widgets. A detailed information can be found
  [here](https://api.highcharts.com/highcharts/series)
  """

  # @spec arrange_series_structure(map, list) :: map
  # def arrange_series_structure(axes, series) do
  #   %{}
  # end

  # this function will return series data in this format:
  # [
  #   %{
  #     data: [
  #       %{"x" => ~U[2020-06-15 08:08:52Z], "y" => "10"},
  #       %{"x" => ~U[2020-06-15 09:55:32Z], "y" => "10"},
  #       %{"x" => ~U[2020-06-15 10:02:12Z], "y" => "10"},
  #       %{"x" => ~U[2020-06-15 12:42:12Z], "y" => "10"},
  #       %{"x" => ~U[2020-06-16 08:08:52Z], "y" => "10"},
  #       %{"x" => ~U[2020-06-16 10:55:32Z], "y" => "10"},
  #       %{"x" => ~U[2020-06-24 10:35:32Z], "y" => "10"}
  #     ],
  #     name: "jane"
  #   },
  #   %{
  #     data: [
  #       %{"x" => ~U[2020-06-15 08:08:52Z], "y" => "16"},
  #       %{"x" => ~U[2020-06-15 09:55:32Z], "y" => "16"},
  #       %{"x" => ~U[2020-06-15 10:03:52Z], "y" => "16"},
  #       %{"x" => ~U[2020-06-15 12:42:12Z], "y" => "16"},
  #       %{"x" => ~U[2020-06-16 02:18:52Z], "y" => "16"},
  #       %{"x" => ~U[2020-06-16 08:08:52Z], "y" => "16"},
  #       %{"x" => ~U[2020-06-17 11:55:32Z], "y" => "16"}
  #     ],
  #     name: "jone"
  #   }
  # ]

  def fetch_highchart_details(widget_inst) do
    filter_metadata = widget_inst.panel.filter_metadata

    filter_metadata =
      if is_nil(filter_metadata) do
        %{
          from_date: Timex.shift(Timex.now(), months: -1) |> DateTime.truncate(:second),
          to_date: Timex.now() |> DateTime.truncate(:second),
          aggregate_func: "max",
          group_interval: "hour"
        }
      else
        widget_inst.panel.filter_metadata
      end

    series_data =
      widget_inst.series_data
      |> arrange_series_structure(widget_inst.widget, filter_metadata)

    Map.put(widget_inst, :series, series_data)
  end

  def parse_properties(properties) do
    Enum.reduce(properties, %{}, fn setting, acc ->
      if (Map.has_key?(setting, :value) && setting.value != %{}) || setting.properties == [] do
        Map.put(acc, setting.key, setting.value["data"])
      else
        value = parse_properties(setting.properties)
        Map.put(acc, setting.key, value)
      end
    end)
  end

  ############################# private functions ###########################

  def arrange_series_structure(
        series_data,
        %{classification: classification},
        filter_metadata
      )
      when classification == "latest" do
    Enum.reduce(series_data, [], fn series, acc_data ->
      nil
      metadata = fetch_latest_axes_spec_data(series.axes, filter_metadata)

      acc_data ++ [%{name: series.name, color: series.color, data: metadata}]
    end)
  end

  def arrange_series_structure(
        series_data,
        %{classification: classification},
        filter_metadata
      )
      when classification != "latest" do
    Enum.reduce(series_data, [], fn series, acc_data ->
      metadata = fetch_axes_specific_data(series.axes, filter_metadata)
      acc_data ++ [%{name: series.name, color: series.color, data: metadata}]
    end)
  end

  defp fetch_latest_axes_spec_data(axes, filter_metadata) do
    Enum.reduce(axes, [], fn axis, acc ->
      res = axis |> validate_data_source(filter_metadata, "latest")
      acc ++ (res || [])
    end)
  end

  defp fetch_axes_specific_data(axes, filter_metadata) do
    Enum.reduce(axes, [], fn axis, acc ->
      res = axis |> validate_data_source(filter_metadata, "timseries")
      acc ++ (res || [])
    end)
  end

  defp validate_data_source(
         %{
           source_type: source_type,
           source_metadata: %{
             "parameter" => parameter,
             "entity_id" => entity_id,
             "entity_type" => entity_type
           }
         },
         filter_metadata,
         type
       )
       when source_type == "pds" and parameter != "inserted_timestamp" do
    fetch_from_data_source(
      entity_id,
      entity_type,
      parameter,
      filter_metadata,
      type
    )
  end

  defp validate_data_source(
         %{
           source_type: source_type,
           source_metadata: %{"parameter" => parameter}
         },
         _filter_metadata,
         _
       )
       when source_type == "pds" and parameter == "inserted_timestamp" do
  end

  defp fetch_from_data_source(
         entity_id,
         entity_type,
         parameter,
         filter_metadata,
         type
       )
       when entity_type == "sensor" and type == "timseries" do
    SensorData.get_all_by_parameters(entity_id, parameter, filter_metadata)
  end

  defp fetch_from_data_source(
         entity_id,
         entity_type,
         parameter,
         filter_metadata,
         type
       )
       when entity_type == "sensor" and type == "latest" do
    data = SensorData.get_latest_by_parameters(entity_id, parameter, filter_metadata)
    data = data |> Map.delete(:x)
    [data]
  end

  defp validate_and_parse_end_date(date) do
    if is_nil(date) || date == "" do
      Timex.now() |> DateTime.truncate(:second)
    else
      parse_date(date)
    end
  end

  defp validate_and_parse_start_date(date, filter_month) do
    if is_nil(date) || date == "" do
      Timex.shift(Timex.now(), months: -filter_month) |> DateTime.truncate(:second)
    else
      parse_date(date)
    end
  end

  defp fetch_uniq_keys(metadata) do
    Enum.reduce(Map.keys(metadata), [], fn x, acc ->
      acc ++ Map.keys(metadata[x])
    end)
  end

  defp parse_series_data(uniq_keys, metadata) do
    Stream.map(uniq_keys, fn key ->
      Enum.reduce(Map.keys(metadata), %{}, fn x, acc ->
        value = metadata[x] |> axes_params_value(key)
        Map.put(acc, x, value)
      end)
    end)
    |> Enum.into([])
  end

  defp axes_params_value(axes, key) when axes == %{} do
    key
  end

  defp axes_params_value(axes, key) when axes != %{} do
    axes[key] || "0"
  end

  defp parse_date(date) do
    date
    |> Timex.parse!("{YYYY}-{0M}-{0D}")
  end
end
