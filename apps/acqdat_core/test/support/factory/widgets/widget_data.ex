defmodule AcqdatCore.Test.Support.WidgetData do
  @data %{
    category: ["chart", "line"],
    data_settings: [
      %{
        data_type: "object",
        key: "axes",
        properties: [
          %{
            data_type: "list",
            key: "x",
            properties: [
              %{
                data_type: "boolean",
                key: "multiple",
                properties: [],
                value: %{data: false}
              }
            ],
            value: %{}
          },
          %{
            data_type: "list",
            key: "y",
            properties: [
              %{
                data_type: "boolean",
                key: "multiple",
                properties: [],
                value: %{data: true}
              }
            ],
            value: %{}
          }
        ],
        value: %{}
      },
      %{
        data_type: "list",
        key: "series",
        properties: [
          %{data_type: "string", key: "color", properties: [], value: %{}},
          %{data_type: "string", key: "name", properties: [], value: %{}}
        ],
        value: %{}
      }
    ],
    default_values: %{
      data_settings_values: %{
        series: [
          %{
            data: [43934, 52503, 57177, 69658, 97031, 119_931, 137_133, 154_175],
            name: 'Installation'
          },
          %{
            data: [24916, 24064, 29742, 29851, 32490, 30282, 38121, 40434],
            name: 'Manufacturing'
          },
          %{
            data: [11744, 17722, 16005, 19771, 20185, 24377, 32147, 39387],
            name: 'Sales & Distribution'
          },
          %{
            data: ['null', 'null', 7988, 12169, 15112, 22452, 34400, 34227],
            name: 'Project Development'
          },
          %{
            data: [12908, 5948, 8105, 11248, 8989, 11816, 18274, 18111],
            name: 'Other'
          }
        ]
      },
      visual_setting_values: %{
        caption: %{
          text: "A brief description of the data being stored by\n                the chart here."
        },
        subtitle: %{text: 'Source: thesolarfoundation.com'},
        title: %{text: 'Solar Employment growth by year'},
        yAxis: %{title: %{text: 'Number of Employees'}}
      }
    },
    image_url:
      "https://assets.highcharts.com/images/demo-thumbnails/highcharts/line-basic-default.png",
    label: "line",
    policies: %{},
    properties: %{},
    uuid: "3cb9d71c763611ea836c482ae331d1eb",
    visual_settings: [
      %{
        data_type: "object",
        key: "caption",
        properties: [
          %{
            data_type: "string",
            key: "text",
            properties: [],
            source: %{},
            user_controlled: true,
            value: %{data: ""}
          },
          %{
            data_type: "string",
            key: "align",
            properties: [],
            source: %{},
            user_controlled: true,
            value: %{data: "left"}
          }
        ],
        source: %{},
        user_controlled: false,
        value: %{}
      },
      %{
        data_type: "object",
        key: "chart",
        properties: [
          %{
            data_type: "string",
            key: "type",
            properties: [],
            source: %{},
            user_controlled: false,
            value: %{data: "line"}
          },
          %{
            data_type: "color",
            key: "backgroundColor",
            properties: [],
            source: %{},
            user_controlled: true,
            value: %{data: "#ffffff"}
          },
          %{
            data_type: "string",
            key: "plotBackgroundColor",
            properties: [],
            source: %{},
            user_controlled: true,
            value: %{data: ""}
          }
        ],
        source: %{},
        user_controlled: false,
        value: %{}
      }
    ],
    widget_type_id: 1
  }

  def data() do
    @data
  end
end
