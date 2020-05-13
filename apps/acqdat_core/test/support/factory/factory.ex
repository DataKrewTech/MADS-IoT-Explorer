defmodule AcqdatCore.Support.Factory do
  use ExMachina.Ecto, repo: AcqdatCore.Repo
  use AcqdatCore.Schema
  use AcqdatCore.Factory.Hierarchy

  alias AcqdatApiWeb.Guardian
  import Plug.Conn

  @access_time_hours 5

  # @image %Plug.Upload{
  #   content_type: "image/png",
  #   filename: "image.png",
  #   path: "test/support/image.png"
  # }

  alias AcqdatCore.Test.Support.WidgetData
  alias AcqdatCore.Widgets.Schema.{Widget, WidgetType}

  alias AcqdatCore.Schema.{
    Sensor,
    DigitalTwin,
    Organisation,
    Asset,
    Gateway,
    Project
  }

  alias AcqdatCore.Schema.RoleManagement.{
    Team,
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

  def organisation_factory() do
    %Organisation{
      name: sequence(:name, &"Org-#{&1}")
    }
  end

  def project_factory() do
    %Project{
      name: sequence(:name, &"Project-#{&1}"),
      uuid: UUID.uuid1(:hex),
      slug: sequence(:sensor_name, &"Project#{&1}"),
      creator: build(:user),
      org: build(:organisation)
    }
  end

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
      uuid: UUID.uuid1(:hex)
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

  def team_factory() do
    %Team{
      name: sequence(:name, &"Team_Name-#{&1}"),
      org: build(:organisation),
      creator: build(:user)
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

  def widget_type_factory() do
    %WidgetType{
      name: sequence(:name, &"Widget_Type-#{&1}"),
      vendor: "Highcharts",
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

  def sensor_factory() do
    %Sensor{
      uuid: UUID.uuid1(:hex),
      name: sequence(:sensor_name, &"Sensor#{&1}"),
      slug: sequence(:sensor_name, &"Sensor#{&1}"),
      org: build(:organisation),
      project: build(:project)
    }
  end

  def gateway_factory() do
    %Gateway{
      uuid: UUID.uuid1(:hex),
      name: sequence(:gateway_name, &"Gateway#{&1}"),
      access_token: sequence(:gateway_name, &"Gateway#{&1}"),
      slug: sequence(:gateway_name, &"Gateway#{&1}"),
      org: build(:organisation),
      project: build(:project)
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

  def organisation() do
    %Organisation{
      uuid: UUID.uuid1(:hex),
      name: sequence(:organisation_name, &"Organisation#{&1}")
    }
  end

  def setup_conn(%{conn: conn}) do
    user = insert(:user)
    org = insert(:organisation)

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

  defp guardian_create_token(resource, time, token_type) do
    Guardian.encode_and_sign(
      resource,
      %{},
      token_type: token_type,
      ttl: time
    )
  end
end
