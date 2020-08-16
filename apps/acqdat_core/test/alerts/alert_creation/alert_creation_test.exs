defmodule AcqdatCore.Alerts.AlertCreationTest do
  @moduledoc """
  Alert creation logics will be tested here
  """
  use ExUnit.Case, async: false
  use AcqdatCore.DataCase
  use AcqdatIotWeb.ConnCase
  alias AcqdatCore.Schema.IotManager.Gateway
  alias AcqdatCore.Model.IotManager.Gateway, as: GModel
  alias AcqdatCore.Alerts.Model.AlertRules
  alias AcqdatCore.Alerts.Schema.Alert, as: AlertSchema
  alias AcqdatCore.Schema.IotManager.GatewayDataDump
  alias AcqdatCore.IotManager.DataParser
  alias AcqdatCore.Repo
  import AcqdatCore.Support.Factory

  describe "create/1" do
    # setup %{} do
    #   # Setting the shared mode so the internal processes share the same db
    #   # conneciton.
    #   Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    # end

    setup :setup_alert_rules

    @doc """
    Here alert rule is created from sensor parameters so this parameters will be passed to gateway for mapping the parameters so that on
    data dump is done we can have a parameter uuid mapped to gateway to generate a alert.
    """
    test "create alert", %{alert_rule: alert_rules, sensor: sensor} do
      {:ok, alert_rules} = AlertRules.create(alert_rules)
      gateway = setup_gateway(sensor)
      data_dump = dump_iot_data(gateway)
      DataParser.start_parsing(data_dump)
      # TODO: have added a small time out so worker processes release db
      # connection, else the test exits and db connection is removed.
      # Need to add a clean way to handle this.
      :timer.sleep(450)
      alert = List.first(Repo.all(AlertSchema))
      assert Map.has_key?(alert, :app)
      assert Map.has_key?(alert, :policy_name)
      assert Map.has_key?(alert, :rule_parameters)
      assert Map.has_key?(alert, :org_id)
      assert Map.has_key?(alert, :assignee_ids)
      assert Map.has_key?(alert, :communication_medium)
      assert Map.has_key?(alert, :creator_id)
      assert Map.has_key?(alert, :entity_id)
      assert Map.has_key?(alert, :entity_name)
      assert Map.has_key?(alert, :status)
      assert Map.has_key?(alert, :severity)
      assert alert.app == alert_rules.app
      assert alert.assignee_ids == alert_rules.assignee_ids
      assert alert.communication_medium == alert_rules.communication_medium
      assert alert.policy_module_name == alert_rules.policy_name
      assert alert.org_id == alert_rules.org_id
      assert alert.creator_id == alert_rules.creator_id
      assert alert.entity_id == alert_rules.entity_id
      assert alert.entity_name == alert_rules.entity
      assert alert.status == :un_resolved
      assert alert.severity == alert_rules.severity
    end

    test "alert not created when alert rule is disabled", %{
      alert_rule: alert_rules,
      sensor: sensor
    } do
      alert_rules = Map.replace!(alert_rules, :status, "disable")
      AlertRules.create(alert_rules)
      gateway = setup_gateway(sensor)
      data_dump = dump_iot_data(gateway)
      DataParser.start_parsing(data_dump)
      # TODO: have added a small time out so worker processes release db
      # connection, else the test exits and db connection is removed.
      # Need to add a clean way to handle this.
      :timer.sleep(150)
      alert = List.first(Repo.all(AlertSchema))
      assert alert == nil
    end
  end

  @doc """
  Here the gateway is inserted in such a wap that mapped parameter will have sensor id and sensor parameter uuid which with threashold value greater then
  Upper limit.
  """
  def setup_gateway(sensor) do
    org = insert(:organisation)
    project = insert(:project, org: org)
    asset = insert(:asset, org: org, project: project)
    gateway = insert_gateway(org, project, asset)
    insert_mapped_parameters(gateway, sensor)
  end

  defp insert_gateway(org, project, asset) do
    params = %{
      uuid: UUID.uuid1(:hex),
      name: "Gateway",
      access_token: "1yJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9",
      slug: "hbGciOiJIUzUxMiIsInR5cCI6I",
      org_id: org.id,
      project_id: project.id,
      parent_id: asset.id,
      parent_type: "Asset",
      channel: "http",
      streaming_data: [
        %{
          name: "Gateway Parameter 1",
          data_type: "integer",
          unit: "cm",
          uuid: UUID.uuid1(:hex)
        },
        %{
          name: "Gateway Parameter 2",
          data_type: "integer",
          unit: "m",
          uuid: UUID.uuid1(:hex)
        }
      ],
      static_data: []
    }

    changeset = Gateway.changeset(%Gateway{}, params)
    Repo.insert!(changeset)
  end

  def setup_alert_rules(_context) do
    sensor = insert(:sensor)
    [param1, _param2] = fetch_parameters(sensor.sensor_type.parameters)
    [user1, user2, user3] = insert_list(3, :user)

    alert_rule = %{
      entity: "sensor",
      entity_id: sensor.id,
      rule_name: "Temperature Status",
      policy_name: "Elixir.AcqdatCore.Alerts.Policies.RangeBased",
      entity_parameters: param1,
      uuid: UUID.uuid1(:hex),
      communication_medium: ["in-app, sms, e-mail"],
      slug: Slugger.slugify(random_string(12)),
      rule_parameters: %{lower_limit: 10, upper_limit: 20},
      # here 0 is added because this is getting converted into charlist
      recepient_ids: [0, user1.id, user2.id],
      assignee_ids: [user3.id],
      policy_type: ["user"],
      severity: "Low",
      status: "enable",
      app: "iot_manager",
      project_id: sensor.project_id,
      org_id: sensor.org_id,
      creator_id: user1.id
    }

    [alert_rule: alert_rule, sensor: sensor]
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end

  defp fetch_parameters(parameters) do
    Enum.reduce(parameters, [], fn param, acc ->
      acc ++ [Map.from_struct(param)]
    end)
  end

  defp insert_mapped_parameters(gateway, sensor) do
    [param1, _param2] = sensor.sensor_type.parameters

    mapped_parameters = %{
      "y_axis" => %{
        "type" => "value",
        "entity" => "sensor",
        "entity_id" => sensor.id,
        "value" => param1.uuid
      }
    }

    {:ok, gateway} = GModel.update(gateway, %{mapped_parameters: mapped_parameters})
    gateway
  end

  defp dump_iot_data(gateway) do
    gateway = Repo.preload(gateway, [:org, :project])

    params = %{
      gateway_id: gateway.id,
      gateway_uuid: gateway.uuid,
      org_uuid: gateway.org.uuid,
      project_uuid: gateway.project.uuid,
      org_id: gateway.org_id,
      project_id: gateway.project_id,
      data: %{
        "y_axis" => 45
      },
      inserted_at: DateTime.to_unix(DateTime.utc_now()),
      inserted_timestamp: DateTime.to_unix(DateTime.utc_now())
    }

    changeset = GatewayDataDump.changeset(%GatewayDataDump{}, params)
    {:ok, data_dump} = Repo.insert(changeset)
    data_dump
  end
end
