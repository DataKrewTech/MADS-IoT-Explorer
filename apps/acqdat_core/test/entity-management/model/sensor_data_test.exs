defmodule AcqdatCore.Model.EntityManagement.SensorDataTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.EntityManagement.SensorData

  describe "create/1" do
    test "creates sensor data successfully" do
      sensor = insert(:sensor)

      params = %{
        parameters: [
          %{
            data_type: "string",
            name: "Voltage",
            value: "456",
            uuid: "ee65c502c66811eabca598460aa1c6de"
          },
          %{
            data_type: "string",
            name: "Voltage",
            value: "459",
            uuid: "ee65c502c66811eabca598460aa1c6de"
          }
        ],
        inserted_timestamp: DateTime.utc_now(),
        sensor_id: sensor.id,
        project_id: sensor.project.id,
        org_id: sensor.org_id
      }

      assert {:ok, _sen_data} = SensorData.create(params)
    end

    test "fails in case of invalid params" do
      params = %{
        parameters: [
          %{
            data_type: "string",
            name: "Voltage",
            value: "456",
            uuid: "ee65c502c66811eabca598460aa1c6de"
          },
          %{
            data_type: "string",
            name: "Voltage",
            value: "459",
            uuid: "ee65c502c66811eabca598460aa1c6de"
          }
        ],
        inserted_timestamp: DateTime.utc_now()
      }

      assert {:error, _sen_data} = SensorData.create(params)
    end
  end

  describe "get_all_by_parameters/3" do
    setup do
      sensor = insert(:sensor)

      params = %{
        parameters: [
          %{
            data_type: "string",
            name: "Voltage",
            value: "456",
            uuid: "ee65c502c66811eabca598460aa1c6de"
          },
          %{
            data_type: "string",
            name: "Voltage",
            value: "459",
            uuid: "ee65c502c66811eabca598460aa1c6de"
          }
        ],
        inserted_timestamp: DateTime.utc_now(),
        sensor_id: sensor.id,
        project_id: sensor.project.id,
        org_id: sensor.org_id
      }

      {:ok, sen_data} = SensorData.create(params)
      [sen_data: sen_data]
    end

    test "returns maximum value as per aggregator specified in filtered data", %{
      sen_data: sen_data
    } do
      filer_params = %{
        from_date: Timex.shift(Timex.now(), months: -1),
        to_date: Timex.now(),
        aggregate_func: "max",
        group_interval: 1,
        group_interval_type: "hour"
      }

      data =
        SensorData.get_all_by_parameters(
          sen_data.sensor_id,
          "ee65c502c66811eabca598460aa1c6de",
          filer_params
        )

      assert not is_nil(data)
      assert data != []
      assert List.last(List.first(data)) == 459.0
    end

    test "returns minimum value as per aggregator specified in filtered data", %{
      sen_data: sen_data
    } do
      filer_params = %{
        from_date: Timex.shift(Timex.now(), months: -1),
        to_date: Timex.now(),
        aggregate_func: "min",
        group_interval: 1,
        group_interval_type: "hour"
      }

      data =
        SensorData.get_all_by_parameters(
          sen_data.sensor_id,
          "ee65c502c66811eabca598460aa1c6de",
          filer_params
        )

      assert not is_nil(data)
      assert data != []
      assert List.last(List.first(data)) == 456.0
    end

    test "returns count value as per aggregator specified in filtered data", %{sen_data: sen_data} do
      filer_params = %{
        from_date: Timex.shift(Timex.now(), months: -1),
        to_date: Timex.now(),
        aggregate_func: "count",
        group_interval: 1,
        group_interval_type: "hour"
      }

      data =
        SensorData.get_all_by_parameters(
          sen_data.sensor_id,
          "ee65c502c66811eabca598460aa1c6de",
          filer_params
        )

      assert not is_nil(data)
      assert data != []
      assert List.last(List.first(data)) == 2
    end

    test "returns sum value as per aggregator specified in filtered data", %{sen_data: sen_data} do
      filer_params = %{
        from_date: Timex.shift(Timex.now(), months: -1),
        to_date: Timex.now(),
        aggregate_func: "sum",
        group_interval: 1,
        group_interval_type: "hour"
      }

      data =
        SensorData.get_all_by_parameters(
          sen_data.sensor_id,
          "ee65c502c66811eabca598460aa1c6de",
          filer_params
        )

      assert not is_nil(data)
      assert data != []
      assert List.last(List.first(data)) == 915.0
    end

    test "returns average value as per aggregator specified in filtered data", %{
      sen_data: sen_data
    } do
      filer_params = %{
        from_date: Timex.shift(Timex.now(), months: -1),
        to_date: Timex.now(),
        aggregate_func: "average",
        group_interval: 1,
        group_interval_type: "hour"
      }

      data =
        SensorData.get_all_by_parameters(
          sen_data.sensor_id,
          "ee65c502c66811eabca598460aa1c6de",
          filer_params
        )

      assert not is_nil(data)
      assert data != []
      assert List.last(List.first(data)) == 457.5
    end

    test "returns empty data if filtered params are not valid", %{sen_data: sen_data} do
      filer_params = %{
        from_date: Timex.now(),
        to_date: Timex.now(),
        aggregate_func: "max",
        group_interval: 1,
        group_interval_type: "hour"
      }

      data =
        SensorData.get_all_by_parameters(
          sen_data.sensor_id,
          "ee65c502c66811eabca598460aa1c6de1",
          filer_params
        )

      assert not is_nil(data)
      assert data == []
    end
  end

  describe "get_latest_by_parameters/3" do
    setup do
      sensor = insert(:sensor)

      params_1 = %{
        parameters: [
          %{
            data_type: "string",
            name: "Voltage",
            value: "456",
            uuid: "ee65c502c66811eabca598460aa1c6de"
          }
        ],
        inserted_timestamp: DateTime.utc_now(),
        sensor_id: sensor.id,
        project_id: sensor.project.id,
        org_id: sensor.org_id
      }

      params_2 = %{
        parameters: [
          %{
            data_type: "string",
            name: "Voltage",
            value: "56",
            uuid: "ee65c502c66811eabca598460aa1c6de"
          }
        ],
        inserted_timestamp: Timex.shift(Timex.now(), months: -1),
        sensor_id: sensor.id,
        project_id: sensor.project.id,
        org_id: sensor.org_id
      }

      SensorData.create(params_2)
      {:ok, sen_data} = SensorData.create(params_1)
      [sen_data: sen_data]
    end

    test "returns maximum value as per aggregator specified in filtered data", %{
      sen_data: sen_data
    } do
      filer_params = %{
        from_date: Timex.shift(Timex.now(), months: -1),
        to_date: Timex.now(),
        aggregate_func: "max",
        group_interval: 1,
        group_interval_type: "hour"
      }

      data =
        SensorData.get_latest_by_parameters(
          sen_data.sensor_id,
          "ee65c502c66811eabca598460aa1c6de",
          filer_params
        )

      assert not is_nil(data)
      assert data.y == 456.0
    end

    test "returns minimum value as per aggregator specified in filtered data", %{
      sen_data: sen_data
    } do
      filer_params = %{
        from_date: Timex.shift(Timex.now(), months: -1),
        to_date: Timex.now(),
        aggregate_func: "min",
        group_interval: 1,
        group_interval_type: "hour"
      }

      data =
        SensorData.get_latest_by_parameters(
          sen_data.sensor_id,
          "ee65c502c66811eabca598460aa1c6de",
          filer_params
        )

      assert not is_nil(data)
      assert data.y == 456.0
    end

    test "returns count value as per aggregator specified in filtered data", %{sen_data: sen_data} do
      filer_params = %{
        from_date: Timex.shift(Timex.now(), months: -1),
        to_date: Timex.now(),
        aggregate_func: "count",
        group_interval: 1,
        group_interval_type: "hour"
      }

      data =
        SensorData.get_latest_by_parameters(
          sen_data.sensor_id,
          "ee65c502c66811eabca598460aa1c6de",
          filer_params
        )

      assert not is_nil(data)
      assert data.y == 1
    end

    test "returns sum value as per aggregator specified in filtered data", %{sen_data: sen_data} do
      filer_params = %{
        from_date: Timex.shift(Timex.now(), months: -1),
        to_date: Timex.now(),
        aggregate_func: "sum",
        group_interval: 1,
        group_interval_type: "hour"
      }

      data =
        SensorData.get_latest_by_parameters(
          sen_data.sensor_id,
          "ee65c502c66811eabca598460aa1c6de",
          filer_params
        )

      assert not is_nil(data)
      assert data.y == 456.0
    end

    test "returns average value as per aggregator specified in filtered data", %{
      sen_data: sen_data
    } do
      filer_params = %{
        from_date: Timex.shift(Timex.now(), months: -1),
        to_date: Timex.now(),
        aggregate_func: "average",
        group_interval: 1,
        group_interval_type: "hour"
      }

      data =
        SensorData.get_latest_by_parameters(
          sen_data.sensor_id,
          "ee65c502c66811eabca598460aa1c6de",
          filer_params
        )

      assert not is_nil(data)
      assert data.y == 456.0
    end

    test "returns empty data if filtered params are not valid", %{sen_data: sen_data} do
      filer_params = %{
        from_date: Timex.now(),
        to_date: Timex.now(),
        aggregate_func: "max",
        group_interval: 1,
        group_interval_type: "hour"
      }

      data =
        SensorData.get_latest_by_parameters(
          sen_data.sensor_id,
          "ee65c502c66811eabca598460aa1c6de1",
          filer_params
        )

      assert is_nil(data)
    end
  end

  describe "get_latest_by_multi_parameters/3" do
    setup do
      sensor = insert(:sensor)

      params_1 = %{
        parameters: [
          %{
            data_type: "string",
            name: "Voltage",
            value: "456",
            uuid: "ee65c502c66811eabca598460aa1c6de"
          }
        ],
        inserted_timestamp: DateTime.utc_now(),
        sensor_id: sensor.id,
        project_id: sensor.project.id,
        org_id: sensor.org_id
      }

      params_2 = %{
        parameters: [
          %{
            data_type: "string",
            name: "Voltage",
            value: "56",
            uuid: "ae65c502c66811eabca598460aa1c6de"
          }
        ],
        inserted_timestamp: Timex.shift(Timex.now(), months: -1),
        sensor_id: sensor.id,
        project_id: sensor.project.id,
        org_id: sensor.org_id
      }

      SensorData.create(params_2)
      {:ok, sen_data} = SensorData.create(params_1)
      [sen_data: sen_data]
    end

    test "returns maximum value as per aggregator specified in filtered data", %{
      sen_data: sen_data
    } do
      filer_params = %{
        from_date: Timex.shift(Timex.now(), months: -1),
        to_date: Timex.now(),
        aggregate_func: "max",
        group_interval: 1,
        group_interval_type: "hour"
      }

      data =
        SensorData.get_latest_by_multi_parameters(
          [sen_data.sensor_id],
          ["ee65c502c66811eabca598460aa1c6de", "ae65c502c66811eabca598460aa1c6de"],
          2,
          filer_params
        )

      assert not is_nil(data)
      assert not is_nil(List.first(data).value)
      assert not is_nil(List.last(data).value)
    end

    test "returns minimum value as per aggregator specified in filtered data", %{
      sen_data: sen_data
    } do
      filer_params = %{
        from_date: Timex.shift(Timex.now(), months: -1),
        to_date: Timex.now(),
        aggregate_func: "min",
        group_interval: 1,
        group_interval_type: "hour"
      }

      data =
        SensorData.get_latest_by_multi_parameters(
          [sen_data.sensor_id],
          ["ee65c502c66811eabca598460aa1c6de", "ae65c502c66811eabca598460aa1c6de"],
          2,
          filer_params
        )

      assert not is_nil(data)
      assert List.first(data).value == 456.0
      assert List.last(data).value == 56.0
    end

    test "returns count value as per aggregator specified in filtered data", %{sen_data: sen_data} do
      filer_params = %{
        from_date: Timex.shift(Timex.now(), months: -1),
        to_date: Timex.now(),
        aggregate_func: "count",
        group_interval: 1,
        group_interval_type: "hour"
      }

      data =
        SensorData.get_latest_by_multi_parameters(
          [sen_data.sensor_id],
          ["ee65c502c66811eabca598460aa1c6de", "ae65c502c66811eabca598460aa1c6de"],
          2,
          filer_params
        )

      assert not is_nil(data)
      assert not is_nil(List.first(data).value)
      assert not is_nil(List.last(data).value)
    end

    test "returns sum value as per aggregator specified in filtered data", %{sen_data: sen_data} do
      filer_params = %{
        from_date: Timex.shift(Timex.now(), months: -1),
        to_date: Timex.now(),
        aggregate_func: "sum",
        group_interval: 1,
        group_interval_type: "hour"
      }

      data =
        SensorData.get_latest_by_multi_parameters(
          [sen_data.sensor_id],
          ["ee65c502c66811eabca598460aa1c6de", "ae65c502c66811eabca598460aa1c6de"],
          2,
          filer_params
        )

      assert not is_nil(data)
      assert List.first(data).value == 456.0
      assert List.last(data).value == 56.0
    end

    test "returns average value as per aggregator specified in filtered data", %{
      sen_data: sen_data
    } do
      filer_params = %{
        from_date: Timex.shift(Timex.now(), months: -1),
        to_date: Timex.now(),
        aggregate_func: "average",
        group_interval: 1,
        group_interval_type: "hour"
      }

      data =
        SensorData.get_latest_by_multi_parameters(
          [sen_data.sensor_id],
          ["ee65c502c66811eabca598460aa1c6de", "ae65c502c66811eabca598460aa1c6de"],
          2,
          filer_params
        )

      assert not is_nil(data)
      assert List.first(data).value == 456.0
      assert List.last(data).value == 56.0
    end
  end
end
