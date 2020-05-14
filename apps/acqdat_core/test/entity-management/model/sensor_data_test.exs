# defmodule AcqdatCore.Model.EntityManagement.SensorDataTest do
#   use ExUnit.Case, async: true
#   use AcqdatCore.DataCase
#   import AcqdatCore.Support.Factory
#   alias AcqdatCore.Model.EntityManagement.{SensorData, Sensor}
#   alias AcqdatCore.Repo

#   describe "get_by_time_range/2" do
#     test "returns data in the given time stamp" do
#       sensor = insert(:sensor)

#       Enum.map(1..4, fn i ->
#         params = %{"temp" => 23 + i, "humid" => 10 + i}
#         Sensor.insert_data(sensor, params)
#       end)

#       start_time = Timex.shift(DateTime.utc_now(), minutes: -1)
#       end_time = DateTime.utc_now()

#       query = SensorData.get_by_time_range(start_time, end_time)
#       result = Repo.all(query)

#       assert length(result) == 4
#     end

#     test "returns empty, if no data in the given time stamp" do
#       sensor = insert(:sensor)

#       Enum.map(1..4, fn i ->
#         params = %{"temp" => 23 + i, "humid" => 10 + i}
#         Sensor.insert_data(sensor, params)
#       end)

#       start_time = Timex.shift(DateTime.utc_now(), minutes: -4)
#       end_time = Timex.shift(DateTime.utc_now(), minutes: -2)

#       query = SensorData.get_by_time_range(start_time, end_time)
#       result = Repo.all(query)

#       assert result == []
#     end
#   end
# end
