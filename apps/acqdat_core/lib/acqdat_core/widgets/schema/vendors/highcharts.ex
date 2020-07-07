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
                  data_type: :string,
                  default_value: "",
                  user_controlled: true
                },
                height: %{data_type: :string, default_value: "", user_controlled: false},
                width: %{data_type: :string, default_value: "", user_controlled: false}
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
                size: %{data_type: :string, default_value: "85%", user_controlled: false},
                background: %{
                  data_type: :list,
                  properties: %{
                    backgroundColor: %{
                      data_type: :string,
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
                    outerRadius: %{data_type: :string, default_value: "", user_controlled: false}
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
                backgroundColor: %{data_type: :string, default_value: "", user_controlled: true},
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

  def arrange_series_structure(series_data) do
    Enum.reduce(series_data, [], fn series, acc_data ->
      metadata = fetch_axes_specific_data(series.axes)

      uniq_keys = metadata |> fetch_uniq_keys |> Stream.uniq()

      parsed_data = uniq_keys |> parse_series_data(metadata)

      acc_data ++ [%{name: series.name, data: parsed_data}]
    end)
  end

  ############################# private functions ###########################

  defp fetch_axes_specific_data(axes) do
    Enum.reduce(axes, %{}, fn axis, acc ->
      res = axis |> validate_data_source
      q = (res || []) |> Enum.map(fn [a, b] -> {a, b} end) |> Map.new()
      Map.put(acc, axis.name, q)
    end)
  end

  defp validate_data_source(%{
         source_type: source_type,
         source_metadata: %{
           "parameter" => parameter,
           "entity_id" => entity_id,
           "entity_type" => entity_type
         }
       })
       when source_type == "pds" and parameter != "inserted_timestamp" do
    fetch_from_data_source(entity_id, entity_type, parameter)
  end

  defp validate_data_source(%{
         source_type: source_type,
         source_metadata: %{"parameter" => parameter}
       })
       when source_type == "pds" and parameter == "inserted_timestamp" do
  end

  defp fetch_from_data_source(entity_id, entity_type, parameter) when entity_type == "sensor" do
    date_from = Timex.shift(Timex.now(), months: -1) |> DateTime.truncate(:second)
    date_to = Timex.now() |> DateTime.truncate(:second)
    SensorData.get_all_by_parameters(entity_id, parameter, date_from, date_to)
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
end
