defmodule AcqdatCore.DataCruncher.Domain.WorkflowTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  import AcqdatCore.Test.Support.SensorsData


  describe "register/1" do
    setup :put_sensor_data

    @timeout :infinity
    @tag sensor_data_quantity: 10
    @tag time_interval_seconds: 5
    test "registers a workflow", context do
      %{sensors: [vibration_sensor, _]} = context
    end
  end
end
