defmodule AcqdatCore.Model.SensorTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  alias AcqdatCore.Model.Sensor

  describe "get_by_id/1" do
    test "returns a particular sensor" do
      sensor = insert(:sensor)

      {:ok, result} = Sensor.get(sensor.id)
      assert not is_nil(result)
      assert result.id == sensor.id
    end

    test "returns error not found, if sensor is not present" do
      {:error, result} = Sensor.get(-1)
      assert result == "not found"
    end
  end

  describe "create/2" do
  end

  describe "update/2" do
  end

  describe "delete" do
  end
end
