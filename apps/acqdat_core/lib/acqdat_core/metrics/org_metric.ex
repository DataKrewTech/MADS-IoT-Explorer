defmodule AcqdatCore.Metrics.OrgMetrics do
  @moduledoc """
  The module exposes all the helpers for getting the metrics for an organisation.
  """

  import Ecto.Query
  import Ecto.Query.API, only: [count: 1]
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.EntityManagement.Organisation
  alias AcqdatCore.Schema.EntityManagement.Asset
  alias AcqdatCore.Schema.EntityManagement.AssetType
  alias AcqdatCore.Schema.EntityManagement.Project
  alias AcqdatCore.Schema.EntityManagement.Sensor
  alias AcqdatCore.Schema.EntityManagement.SensorType
  alias AcqdatCore.Schema.IotManager.Gateway
  alias AcqdatCore.Schema.EntityManagement.SensorsData
  alias AcqdatCore.DashboardManagement.Schema.Dashboard
  alias AcqdatCore.DashboardManagement.Schema.Panel
  alias AcqdatCore.DashboardManagement.Schema.WidgetInstance
  alias AcqdatCore.DataInsights.Schema.FactTables
  alias AcqdatCore.DataInsights.Schema.Visualizations


  @doc """
  Calculates all the parameters to be checked for an organisation and stores
  them in the database.
  """
  def measure_and_dump() do
    orgs = Repo.all(Organisation)
    stream = Task.async_stream(orgs, &assimilate_all_metrics/1, ordered: false)
    Enum.to_list(stream)
  end

  def assimilate_all_metrics(org) do
    data = org.id
      |> entity_manifest()
      |> Map.merge(dashboard_manifest(org.id))
      |> Map.merge(data_insights_manifest(org.id))
  end

  # Get projects, assets, asset_types, sensors, sensor_types, gateways,
  # active parameters, for calculting active parameters use the current time
  # for day beginning and day end.
  def entity_manifest(org_id) do
    {asset_query, sensor_query, project_query} = entities_query(org_id)

    sensor_result = parse_sensors_data(sensor_query)
    asset_result = parse_asset_data(asset_query)
    project_result = parse_project_data(project_query)

    parameters_query = parameters_query(org_id, Timex.now())
    parameters_result = parse_parameters_data(parameters_query)

    %{
      entities: %{
        sensors: %{count: sensor_result.sensor_count,
          metadata: %{data: sensor_result.sensor_meta}},
        sensor_types: %{count: sensor_result.sensor_type_count,
          metadata: %{data: sensor_result.sensor_type_meta}},
        assets: %{count: asset_result.asset_count,
          metadata: %{data: asset_result.asset_meta}},
        asset_types: %{count: asset_result.asset_type_count,
          metadata: %{data: asset_result.asset_type_meta}},
        projects: %{count: project_result.project_count,
          metadata: %{data: project_result.project_meta}},
        gateways: %{count: project_result.gateway_count,
          metadata: %{data: project_result.gateway_meta}},
        active_parameters: %{
          count: parameters_result.parameter_count,
          metadata: parameters_result.parameter_meta
        }
      }
    }
  end

  # Get all dashboards, projects and widgets.
  def dashboard_manifest(org_id) do
    query = dashboard_query(org_id)
    dashboard_results = parse_dashboard_parameters(query)

    %{
      dashboards: %{
        dashboards: %{count: dashboard_results.dashboard_count,
          metadata: %{data: dashboard_results.dashboard_meta},
        },
        panels:  %{count: dashboard_results.panel_count,
          metadata: %{data: dashboard_results.panel_meta},
        },
        widgets:  %{count: dashboard_results.widget_count,
          metadata: %{data: dashboard_results.widget_meta},
        }
      }
    }
  end

  # Get all fact tables and visualisations
  def data_insights_manifest(org_id) do
    query = data_insights_query(org_id)
    results = parse_data_insights_query(query)

    %{ data_insights:
      %{
        fact_tables: %{count: results.fact_table_count,
          metadata: %{data: results.fact_table_meta}},
        visualisations: %{count: results.visualisation_count,
          metadata: %{data: results.visualisation_meta}
        }
      }
    }
  end

  # Get user information
  defp role_manager_manifest(org_id) do

  end

  # Get database size being used by an organisation
  #TODO implement database usage per organisation
  defp db_storage(org_id) do

  end

  def entities_query(org_id) do
    asset_query = from(
      asset_type in AssetType,
      left_join: asset in Asset, on: asset.asset_type_id == asset_type.id,
      where: asset_type.org_id == ^org_id,
      group_by: [asset_type.id, asset_type.name],
      select: %{
        asset_type_id: asset_type.id,
        asset_type_name: asset_type.name,
        asset_data: fragment("array_agg((?, ?))", asset.name, asset.id),
        asset_count: count(asset.id)
      }
    )

    sensor_query = from(
      sensor_type in SensorType,
      left_join: sensor in Sensor, on: sensor.sensor_type_id == sensor_type.id,
      where: sensor_type.org_id == ^org_id,
      group_by: [sensor_type.id, sensor_type.name],
      select: %{
        sensor_type_id: sensor_type.id,
        sensor_type_name: sensor_type.name,
        sensor_data: fragment("array_agg((?,?))", sensor.name, sensor.id),
        sensor_count: count(sensor.id)
      }
    )

    project_query = from(
      project in Project,
      left_join: gateway in Gateway, on: gateway.project_id == project.id,
      group_by: [project.name, project.id],
      where: project.org_id == ^org_id,
      select: %{
        project_name: project.name,
        project_id: project.id,
        gateway: fragment("array_agg((?,?))", gateway.name, gateway.id),
        gateway_count: count(gateway.id)
      }
    )

    {asset_query, sensor_query, project_query}
  end

  # Gets the result of all the active parameters for the past day.
  # Active parameters are all the sensor parameters which have sent data on that
  # particular day. See `AcqdatCore.Schema.EntityManagement.SensorsData`
  # and `AcqdatCore.Schema.EntityManagement.Sensors`.
  def parameters_query(org_id, time) do
    start_time = Timex.shift(time, days: -1)
    end_time = time

    subquery1 = from(
      sensor_data in SensorsData,
      where: sensor_data.org_id == ^org_id
        and sensor_data.inserted_timestamp > ^start_time
        and sensor_data.inserted_timestamp < ^end_time,
      distinct: true,
      select: %{sensor_id: sensor_data.sensor_id}
    )

    from(
      sensor in Sensor,
      join: q in subquery(subquery1), on: sensor.id == q.sensor_id,
      join: sensor_type in SensorType, on: sensor.sensor_type_id == sensor_type.id,
      select: {sensor.id, sensor.name, sensor_type.parameters}
    )
  end

  defp parse_sensors_data(query) do
    result = Repo.all(query)
    acc = %{sensor_count: 0, sensor_type_count: 0, sensor_type_meta: [], sensor_meta: []}
    Enum.reduce(result, acc, fn
      %{sensor_count: 0} = data, acc ->
        %{sensor_type_count: sensor_type_count, sensor_type_meta: sensor_type_meta} = acc
        %{
          acc | sensor_type_count: sensor_type_count + 1,
          sensor_type_meta: [{data.sensor_type_id, data.sensor_type_name} | sensor_type_meta]
        }
      data, acc ->
        %{sensor_type_count: sensor_type_count,
          sensor_type_meta: sensor_type_meta, sensor_count: sensor_count,
          sensor_meta: sensor_meta
          } = acc

        %{acc | sensor_type_count: sensor_type_count + 1,
          sensor_type_meta: [{data.sensor_type_id, data.sensor_type_name} | sensor_type_meta],
          sensor_count: sensor_count + data.sensor_count,
          sensor_meta: data.sensor_data ++ sensor_meta
        }
    end)
  end

  defp parse_asset_data(query) do
    result = Repo.all(query)
    acc = %{asset_count: 0, asset_type_count: 0, asset_type_meta: [], asset_meta: []}

    Enum.reduce(result, acc, fn
      %{asset_count: 0} = data, acc ->
        %{asset_type_count: asset_type_count, asset_type_meta: asset_type_meta} = acc
        %{
          acc | asset_type_count: asset_type_count + 1,
          asset_type_meta: [{data.asset_type_id, data.asset_type_name} | asset_type_meta]
        }
        data, acc ->
          %{asset_type_count: asset_type_count,
          asset_type_meta: asset_type_meta, asset_count: asset_count,
          asset_meta: asset_meta
          } = acc

          %{acc | asset_type_count: asset_type_count + 1,
          asset_type_meta: [{data.asset_type_id, data.asset_type_name} | asset_type_meta],
          asset_count: asset_count + data.asset_count,
          asset_meta: data.asset_data ++ asset_meta
        }
      end)
  end

  defp parse_project_data(query) do
    result = Repo.all(query)
    acc = %{project_count: 0, project_meta: [], gateway_count: 0, gateway_meta: []}
    Enum.reduce(result, acc, fn
      %{gateway_count: 0} = data, acc ->
        %{project_count: project_count, project_meta: project_meta} = acc
        %{
          acc | project_count: project_count+1,
          project_meta: [{data.project_id, data.project_name} | project_meta]
        }
      data, acc ->
        %{project_count: project_count, project_meta: project_meta,
          gateway_count: gateway_count, gateway_meta: gateway_meta} = acc
        %{acc | project_count: project_count+1,
        project_meta: [{data.project_id, data.project_name} | project_meta],
        gateway_count: gateway_count + data.gateway_count,
        gateway_meta: data.gateway ++ gateway_meta
      }
    end)
  end

  defp parse_parameters_data(query) do
    result = Repo.all(query)
    acc = %{parameter_count: 0, parameter_meta: []}
    Enum.reduce(result, acc, fn {sensor_id, sensor_name, params}, acc ->
      parameter_count = length(params) + acc.parameter_count
      parameter_meta = [ {sensor_id, sensor_name} | acc.parameter_meta]
      %{acc | parameter_count: parameter_count, parameter_meta: parameter_meta}
    end)
  end

  def dashboard_query(org_id) do
    subquery1 = from(
      panel in Panel,
      left_join: instance in WidgetInstance, on: instance.panel_id == panel.id,
      where: panel.org_id == ^org_id,
      group_by: [panel.id, panel.name],
      select: %{
        panel_id: panel.id,
        panel_name: panel.name,
        widget_instance_data: fragment("array_agg((?, ?))", instance.uuid, instance.label),
        dashboard_id: panel.dashboard_id,
        widget_count: count(instance.uuid)
      }
    )

    from(
      dashboard in Dashboard,
      left_join: q1 in subquery(subquery1), on: q1.dashboard_id == dashboard.id,
      group_by: [dashboard.id, dashboard.name],
      where: dashboard.org_id == ^org_id,
      select: %{
        dashboard_id: dashboard.id,
        dashboard_name: dashboard.name,
        panel_data: fragment("to_json(array_agg((?,?,?,?)))", q1.panel_id,
          q1.panel_name, q1.widget_instance_data, q1.widget_count)
      }
    )
  end

  defp parse_dashboard_parameters(query) do
    result = Repo.all(query)
    acc = %{dashboard_count: 0, dashboard_meta: [],
      panel_count: 0, panel_meta: [], widget_count: 0, widget_meta: []}

    Enum.reduce(result, acc, fn data, acc ->
      panel_acc = %{panel_count: acc.panel_count, panel_meta: acc.panel_meta,
        widget_count: acc.widget_count, widget_meta: acc.widget_meta}
      panel_data = Enum.reduce(data.panel_data, panel_acc, fn
        %{"f4" => 0} = panel_data, panel_acc ->
          %{panel_acc | panel_count: panel_acc.panel_count + 1,
            panel_meta: [{panel_data["f1"], panel_data["f2"]} | panel_acc.panel_meta]}
        panel_data, panel_acc ->
          widget_meta = Enum.map(panel_data["f3"], fn data ->
            {data["f1"], data["f2"]}
          end)
          widget_count = panel_data["f4"]

          %{panel_acc | panel_count: panel_acc.panel_count+1,
            panel_meta: [{panel_data["f1"], panel_data["f2"]} | panel_acc.panel_meta],
            widget_count: widget_count + panel_acc.widget_count,
            widget_meta: panel_acc.widget_meta ++ widget_meta
          }
      end)

      %{
        acc |
        dashboard_count: acc.dashboard_count + 1,
        dashboard_meta: [{data.dashboard_id, data.dashboard_name} | acc.dashboard_meta],
        panel_count: panel_data.panel_count,
        panel_meta: panel_data.panel_meta,
        widget_count: panel_data.widget_count,
        widget_meta: panel_data.widget_meta
      }
    end)
  end

  defp data_insights_query(org_id) do
    from(
      table in FactTables,
      left_join: visual in Visualizations, on: table.id == visual.fact_table_id,
      where: table.org_id == ^org_id,
      group_by: [table.id, table.name],
      select: %{
        table_id: table.id,
        table_name: table.name,
        visualisation: fragment("array_agg((?,?))", visual.id, visual.name),
        visualisation_count: count(visual.id)
      }
    )
  end

  defp parse_data_insights_query(query) do
    result = Repo.all(query)
    acc = %{fact_table_count: 0, fact_table_meta: [], visualisation_count: 0,
      visualisation_meta: []}

    Enum.reduce(result, acc, fn
      %{visualisation_count: 0} = data, acc ->
        table_count = acc.fact_table_count + 1
        table_meta = [{data.table_id, data.table_name} | acc.fact_table_meta]
        %{acc | fact_table_count: table_count, fact_table_meta: table_meta}
      data, acc ->
        viz_count = data.visualisation_count + acc.visualisation_count
        viz_meta = data.visualisation ++ acc.visualisation_meta
        table_count = acc.fact_table_count + 1
        table_meta = [{data.table_id, data.table_name} | acc.fact_table_meta]
        %{acc | fact_table_count: table_count, fact_table_meta: table_meta,
          visualisation_count: viz_count, visualisation_meta: viz_meta
        }
      end)
  end

end
