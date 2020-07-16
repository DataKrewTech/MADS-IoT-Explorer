defmodule AcqdatIotWeb.DataParserTest do
  # Tests are being run with async false as it leads to deadlock
  # situtation. Check server logs after setting async: true.

  use ExUnit.Case, async: false
  use AcqdatCore.DataCase
  alias AcqdatIot.DataParser
  alias AcqdatCore.Schema.EntityManagement.SensorsData
  alias AcqdatCore.Schema.EntityManagement.GatewayData
  alias AcqdatCore.Schema.IotManager.GatewayDataDump, as: GDD
  alias AcqdatCore.Test.Support.DataDump
  alias AcqdatCore.Repo

  describe "data parser test/1" do
    test "data parser" do
      [data_dump, _sensor1, _sensor2, gateway] = DataDump.setup_gateway()
      DataParser.start_parsing(struct(GDD, data_dump))
      sensors_data = Repo.all(SensorsData)
      [gateway_data] = Repo.all(GatewayData)
      %{data: data} = data_dump
      [z_axis_data1, z_axis_data2] = data["axis_object"]["z_axis"]
      %{"axis_object" => axis_object, "y_axis" => y_axis} = gateway.mapped_parameters

      %{
        "value" => %{
          "lambda" => %{"value" => %{"alpha" => alpha, "beta" => beta}},
          "x_axis" => x_axis,
          "z_axis" => %{"value" => [z_axis1, _z_axis2]}
        }
      } = axis_object

      Enum.each(gateway_data.parameters, fn parameter ->
        if parameter.uuid == y_axis["value"] do
          assert parameter.value == data["y_axis"]
        else
          if parameter.uuid == beta["value"] do
            assert parameter.value == data["axis_object"]["lambda"]["beta"]
          end
        end
      end)

      Enum.each(sensors_data, fn sensor_data ->
        Enum.each(sensor_data.parameters, fn parameter ->
          if parameter.uuid == x_axis["value"] do
            assert parameter.value == data["axis_object"]["x_axis"]
          else
            if parameter.uuid == alpha["value"] do
              assert parameter.value == data["axis_object"]["lambda"]["alpha"]
            else
              if parameter.uuid == z_axis1["value"] do
                assert parameter.value == z_axis_data1
              else
                assert parameter.value == z_axis_data2
              end
            end
          end
        end)
      end)
    end
  end
end
