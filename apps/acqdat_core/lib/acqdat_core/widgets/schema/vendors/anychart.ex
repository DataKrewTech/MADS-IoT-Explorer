defmodule AcqdatCore.Widgets.Schema.Vendors.AnyChart do
  @moduledoc """
    Embedded Schema of the settings of the widget with it keys and subkeys
  """

  defstruct anychart: %{
              data_type: :object,
              user_controlled: false,
              properties: %{
                type: %{data_type: :string, default_value: "", user_controlled: false}
              }
            },
            title: %{
              data_type: :object,
              user_controlled: false,
              properties: %{
                text: %{data_type: :string, default_value: "", user_controlled: true}
              }
            },
            series: %{
              data_type: :list,
              user_defined: false,
              properties: %{}
            }
end
