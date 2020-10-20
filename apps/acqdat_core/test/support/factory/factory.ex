defmodule AcqdatCore.Support.Factory do
  use ExMachina.Ecto, repo: AcqdatCore.Repo
  use AcqdatCore.Schema
  use AcqdatCore.Factory.Hierarchy
  use AcqdatCore.Factory.Alerts

  alias AcqdatApiWeb.Guardian
  import Plug.Conn

  @access_time_hours 5

  alias AcqdatCore.Test.Support.WidgetData
  alias AcqdatCore.Widgets.Schema.{Widget, WidgetType}
  alias AcqdatCore.Schema.DigitalTwin
  alias AcqdatCore.Schema.IotManager.Gateway
  alias AcqdatCore.DashboardExport.Schema.DashboardExport

  alias AcqdatCore.DashboardManagement.Schema.{
    Dashboard,
    Panel,
    WidgetInstance,
    CommandWidget
  }

  alias AcqdatCore.DataCruncher.Schema.{Tasks, Workflow}

  alias AcqdatCore.Schema.EntityManagement.{
    Sensor,
    Organisation,
    AssetType,
    Asset,
    Project,
    SensorType,
    AssetType,
    SensorsData
  }

  alias AcqdatCore.Schema.RoleManagement.{
    User,
    UserSetting,
    Role,
    App,
    Invitation
  }

  alias AcqdatCore.Schema.ToolManagement.{
    Employee,
    ToolType,
    ToolBox,
    Tool,
    ToolIssue,
    ToolReturn
  }

  def user_factory() do
    %User{
      first_name: sequence(:first_name, &"Tony-#{&1}"),
      last_name: sequence(:last_name, &"Stark-#{&1}"),
      email: sequence(:email, &"ceo-#{&1}@stark.com"),
      password_hash: "NOTASECRET",
      role: build(:role),
      org: build(:organisation)
    }
  end

  def app_factory() do
    %App{
      name: sequence(:name, &"App_Name-#{&1}"),
      description: "Demo App Testing",
      uuid: UUID.uuid1(:hex),
      key: sequence(:key, &"Key_Name-#{&1}")
    }
  end

  def invitation_factory() do
    %Invitation{
      email: sequence(:email, &"ceo-#{&1}@stark.com"),
      token: UUID.uuid1(:hex),
      salt: UUID.uuid1(:hex),
      inviter: build(:user),
      role: build(:role),
      org: build(:organisation)
    }
  end

  def user_setting_factory() do
    %UserSetting{
      visual_settings: %{
        "recently_visited_apps" => ["data_cruncher", "support", "settings", "dashboard"],
        "taskbar_pos" => "left",
        "desktop_wallpaper" => "default.png"
      },
      data_settings: %{
        "latitude" => 11.2,
        "longitude" => 20.22
      }
    }
  end

  def role_factory() do
    %Role{
      name: sequence(:name, &"Role-#{&1}"),
      description: "Member of the organisation"
    }
  end

  def dashboard_factory() do
    %Dashboard{
      uuid: UUID.uuid1(:hex),
      name: sequence(:dashboard_name, &"Dashboard#{&1}"),
      slug: sequence(:dashboard_name, &"Dashboard#{&1}"),
      org: build(:organisation)
    }
  end

  def dashboard_export_factory() do
    %DashboardExport{
      dashboard_uuid: UUID.uuid1(:hex),
      token: UUID.uuid1(:hex),
      url: UUID.uuid1(:hex),
      is_secure: false,
      dashboard: build(:dashboard)
    }
  end

  def panel_factory() do
    %Panel{
      uuid: UUID.uuid1(:hex),
      name: sequence(:dashboard_name, &"Panel#{&1}"),
      slug: sequence(:dashboard_name, &"Panel#{&1}"),
      dashboard: build(:dashboard),
      org: build(:organisation)
    }
  end

  def command_widget_factory() do
    %CommandWidget{
      uuid: UUID.uuid1(:hex),
      label: "LED Control",
      properties: %{},
      module: "Elixir.AcqdatCore.DashboardManagement.Schema.CommandWidget.LEDControl",
      command_widget_type: "html",
      gateway: build(:gateway),
      panel: build(:panel),
      data_settings: %{},
      visual_settings: %{}
    }
  end

  def widget_instance_factory() do
    %WidgetInstance{
      uuid: UUID.uuid1(:hex),
      label: sequence(:widget_inst_name, &"WidgetInstance#{&1}"),
      slug: sequence(:widget_inst_name, &"WidgetInstance#{&1}"),
      panel: build(:panel),
      widget: build(:widget)
    }
  end

  def widget_type_factory() do
    %WidgetType{
      name: sequence(:name, &"Widget_Type-#{&1}"),
      vendor: "HighCharts",
      module: "Elixir.AcqdatCore.Widgets.Schema.Vendors.HighCharts",
      vendor_metadata: %{}
    }
  end

  def widget_factory() do
    widget_params = WidgetData.data()
    widget_type = insert(:widget_type)

    widget_params =
      Map.replace!(widget_params, :widget_type_id, widget_type.id)
      |> Map.put_new(:widget_type, widget_type)

    # widget = Widget.changeset(%Widget{}, widget_params)
    struct(%Widget{}, widget_params)
  end

  def set_password(user, password) do
    user
    |> User.changeset(%{password: password, password_confirmation: password})
    |> Ecto.Changeset.apply_changes()
  end

  def digital_twin_factory() do
    %DigitalTwin{
      name: sequence(:digital_twin, &"digital_twin#{&1}")
    }
  end

  def tasks_factory() do
    %Tasks{
      name: sequence(:tasks, &"tasks#{&1}"),
      slug: sequence(:tasks, &"tasks#{&1}"),
      uuid: UUID.uuid1(:hex),
      user: build(:user),
      org: build(:organisation)
    }
  end

  def workflow_factory() do
    %Workflow{
      uuid: UUID.uuid1(:hex),
      task: build(:tasks),
      graph: %{
        name: sequence(:Graph, &"Graph#{&1}"),
        data_type: sequence(:Graph, &"Graph#{&1}"),
        unit: sequence(:Graph, &"Graph#{&1}")
      },
      input_data: [
        %{
          name: sequence(:input_data, &"input_data#{&1}"),
          data_type: sequence(:input_data, &"input_data#{&1}"),
          unit: sequence(:input_data, &"input_data#{&1}")
        }
      ]
    }
  end

  def asset_type_factory() do
    %AssetType{
      name: sequence(:asset_type_name, &"AssetType#{&1}"),
      slug: sequence(:asset_type_name, &"AssetType#{&1}"),
      uuid: UUID.uuid1(:hex),
      project: build(:project),
      org: build(:organisation),
      parameters: [
        %{
          name: sequence(:asset_type_name, &"AssetTypeParam#{&1}"),
          data_type: sequence(:asset_type_name, &"AssetTypeDataType#{&1}"),
          unit: sequence(:asset_type_name, &"AssetTypeUnit#{&1}")
        },
        %{
          name: sequence(:asset_type_name, &"AssetTypeParam#{&1}"),
          data_type: sequence(:asset_type_name, &"AssetTypeDataType#{&1}"),
          unit: sequence(:asset_type_name, &"AssetTypeUnit#{&1}")
        }
      ],
      metadata: [
        %{
          name: sequence(:asset_type_name, &"AssetTypeParam#{&1}"),
          data_type: sequence(:asset_type_name, &"AssetTypeDataType#{&1}"),
          unit: sequence(:asset_type_name, &"AssetTypeUnit#{&1}")
        },
        %{
          name: sequence(:asset_type_name, &"AssetTypeParam#{&1}"),
          data_type: sequence(:asset_type_name, &"AssetTypeDataType#{&1}"),
          unit: sequence(:asset_type_name, &"AssetTypeUnit#{&1}")
        }
      ]
    }
  end

  def sensor_factory() do
    %Sensor{
      uuid: UUID.uuid1(:hex),
      name: sequence(:sensor_name, &"Sensor#{&1}"),
      slug: sequence(:sensor_name, &"Sensor#{&1}"),
      org: build(:organisation),
      project: build(:project),
      sensor_type: build(:sensor_type),
      gateway: build(:gateway)
    }
  end

  def sensor_type_factory() do
    %SensorType{
      name: sequence(:sensor_type_name, &"SensorType#{&1}"),
      slug: sequence(:sensor_type_name, &"SensorType#{&1}"),
      uuid: UUID.uuid1(:hex),
      org: build(:organisation),
      project: build(:project),
      parameters: [
        %{
          name: sequence(:sensor_type_name, &"SensorTypeParam#{&1}"),
          data_type: sequence(:sensor_type_name, &"SensorTypeDataType#{&1}"),
          unit: sequence(:sensor_type_name, &"SensorTypeUnit#{&1}"),
          uuid: UUID.uuid1(:hex)
        },
        %{
          name: sequence(:sensor_type_name, &"SensorTypeParam#{&1}"),
          data_type: sequence(:sensor_type_name, &"SensorTypeDataType#{&1}"),
          unit: sequence(:sensor_type_name, &"SensorTypeUnit#{&1}"),
          uuid: UUID.uuid1(:hex)
        }
      ],
      metadata: [
        %{
          name: sequence(:sensor_type_name, &"SensorTypeParam#{&1}"),
          data_type: sequence(:sensor_type_name, &"SensorTypeDataType#{&1}"),
          unit: sequence(:sensor_type_name, &"SensorTypeUnit#{&1}")
        },
        %{
          name: sequence(:sensor_type_name, &"SensorTypeParam#{&1}"),
          data_type: sequence(:sensor_type_name, &"SensorTypeDataType#{&1}"),
          unit: sequence(:sensor_type_name, &"SensorTypeUnit#{&1}")
        }
      ]
    }
  end

  def gateway_factory() do
    asset = insert(:asset)

    %Gateway{
      uuid: UUID.uuid1(:hex),
      name: sequence(:gateway_name, &"Gateway#{&1}"),
      access_token: random_string(64),
      slug: sequence(:gateway_name, &"Gateway#{&1}"),
      org: build(:organisation),
      project: build(:project),
      parent_id: asset.id,
      parent_type: "Asset",
      channel: "http",
      mapped_parameters: %{},
      timestamp_mapping: nil,
      streaming_data: [],
      static_data: []
    }
  end

  def employee_factory() do
    %Employee{
      name: sequence(:employee_name, &"Employee#{&1}"),
      phone_number: "123456",
      address: "54 Peach Street, Gotham",
      role: "big boss",
      uuid: "U" <> permalink(4)
    }
  end

  def tool_type_factory() do
    %ToolType{
      identifier: sequence(:tl_type_identifier, &"ToolType#{&1}")
    }
  end

  def tool_box_factory() do
    %ToolBox{
      name: sequence(:employee_name, &"ToolBox#{&1}"),
      uuid: "TB" <> permalink(4),
      description: "Tool box at Djaya"
    }
  end

  def tool_factory() do
    %Tool{
      name: sequence(:employee_name, &"Tool#{&1}"),
      uuid: "T" <> permalink(4),
      status: "in_inventory",
      tool_box: build(:tool_box),
      tool_type: build(:tool_type)
    }
  end

  def employee_list(%{employee_count: count}) do
    employees = insert_list(count, :employee)
    [employees: employees]
  end

  def tool_list(%{tool_count: count, tool_box: tool_box}) do
    tools = insert_list(count, :tool, tool_box: tool_box)
    [tools: tools]
  end

  def tool_issue_factory() do
    %ToolIssue{
      employee: build(:employee),
      tool: build(:tool),
      tool_box: build(:tool_box),
      issue_time: DateTime.truncate(DateTime.utc_now(), :second)
    }
  end

  def tool_return(tool_issue) do
    return_params = %{
      employee_id: tool_issue.employee_id,
      tool_id: tool_issue.tool.id,
      tool_box_id: tool_issue.tool_box.id,
      tool_issue_id: tool_issue.id,
      return_time: DateTime.truncate(DateTime.utc_now(), :second)
    }

    changeset = ToolReturn.changeset(%ToolReturn{}, return_params)
    Repo.insert(changeset)
  end

  # TODO: This should not be here, it's the responsibility of acqdat_api.
  def setup_conn(%{conn: conn}) do
    org = insert(:organisation)
    user = insert(:user, org: org)

    {:ok, access_token, _claims} =
      guardian_create_token(
        user,
        {@access_time_hours, :hours},
        :access
      )

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Bearer #{access_token}")

    [conn: conn, user: user, org: org]
  end

  # Remove this from here. Responsibility of API app.
  defp guardian_create_token(resource, time, token_type) do
    Guardian.encode_and_sign(
      resource,
      %{},
      token_type: token_type,
      ttl: time
    )
  end

  def sensors_data_factory() do
    %SensorsData{
      inserted_timestamp: DateTime.truncate(DateTime.utc_now(), :second),
      sensor_id: 1,
      org_id: 1,
      project_id: 1,
      parameters: [
        %{
          name: sequence(:sensors_data, &"SensorsData#{&1}"),
          data_type: sequence(:sensors_data, &"SensorsData#{&1}"),
          value: sequence(:sensors_data, &"SensorsData#{&1}"),
          uuid: "771e9f94b49511eabc9998460aa1c6de"
        },
        %{
          name: sequence(:sensors_data, &"SensorsData#{&1}"),
          data_type: sequence(:sensors_data, &"SensorsData#{&1}"),
          value: sequence(:sensors_data, &"SensorsData#{&1}"),
          uuid: "771e9f94b49511eabc9998460aa1c6de"
        }
      ]
    }
  end
end
