defmodule AcqdatApi.EntityParserTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatApi.EntityManagement.EntityParser
  alias AcqdatCore.Schema.EntityManagement.{Project, Asset, Sensor}
  alias AcqdatCore.Model.EntityManagement.Asset, as: AssetModel
  alias AcqdatCore.Repo

  describe "update_hierarchy/2" do
    setup do
      project = insert(:project)
      current_user = insert(:user)
      asset_type = insert(:asset_type)
      sensor_type = insert(:sensor_type)

      [
        project: project,
        current_user: current_user,
        asset_type: asset_type,
        sensor_type: sensor_type
      ]
    end

    test "returns success and increments project version if hirerachy tree has been updated successfully",
         %{project: project, current_user: current_user, asset_type: asset_type} do
      assert {:ok, message} =
               EntityParser.update_project_hierarchy(
                 current_user,
                 project,
                 valid_hierarchy_tree_params(project, asset_type)
               )

      updated_proj = Repo.get(Project, project.id)
      assert updated_proj.version == Decimal.add(project.version, "0.1")
    end

    test "returns errors when project version in the request params does not match with current version",
         %{project: project, current_user: current_user} do
      assert {:error, message} =
               EntityParser.update_project_hierarchy(
                 current_user,
                 project,
                 invalid_project_version_params(project)
               )

      assert message == ["Please update your current tree version"]
    end

    test "successfully create asset tree with Sensors as descendants", %{
      project: project,
      current_user: current_user,
      asset_type: asset_type,
      sensor_type: sensor_type
    } do
      assert length(Repo.all(Asset)) == 0
      assert length(Repo.all(Sensor)) == 0

      assert {:ok, message} =
               EntityParser.update_project_hierarchy(
                 current_user,
                 project,
                 valid_asset_tree_with_sensors_creation_params(project, asset_type, sensor_type)
               )

      assert length(Repo.all(Asset)) == 1
      assert length(Repo.all(Sensor)) == 2
    end

    test "update sensor details of hirerachy", %{
      project: project,
      current_user: current_user,
      asset_type: asset_type
    } do
      {:ok, asset} = create_root_asset(project, asset_type, current_user)
      {:ok, sensor} = create_child_sensors(asset)

      assert {:ok, message} =
               EntityParser.update_project_hierarchy(
                 current_user,
                 project,
                 update_sensor_tree_params(project, asset, sensor)
               )

      updated_sensor = Repo.get(Sensor, sensor.id)
      assert updated_sensor.name == "updated #{sensor.name}"
    end

    test "successfully deletes sensor which doesn't have any data", %{
      project: project,
      current_user: current_user
    } do
      sensor_manifest = build(:sensor, parent_id: project.id, parent_type: "Project")

      {:ok, sensor} = Repo.insert(sensor_manifest)

      params = %{
        "entities" => [
          %{
            "entities" => [
              %{
                "name" => sensor.name,
                "type" => "Sensor",
                "action" => "delete",
                "id" => sensor.id,
                "parent_id" => project.id
              }
            ],
            "id" => project.id,
            "name" => "demo project",
            "slug" => "So53BFRd92wb",
            "type" => "Project",
            "version" => "1.0"
          }
        ],
        "id" => project.org_id,
        "org_id" => "#{project.org_id}",
        "name" => "DataKrew",
        "type" => "Organisation"
      }

      refute is_nil(Repo.get(Sensor, sensor.id))
      assert {:ok, message} = EntityParser.update_project_hierarchy(current_user, project, params)
      assert is_nil(Repo.get(Sensor, sensor.id))
    end

    test "return errors if sensor contains data, during deletion", %{
      project: project,
      current_user: current_user
    } do
      sensor_manifest =
        build(:sensor, parent_id: project.id, parent_type: "Project", has_timesrs_data: true)

      {:ok, sensor} = Repo.insert(sensor_manifest)

      sensor_data = build(:sensors_data, sensor_id: sensor.id, org_id: sensor.org_id)

      {:ok, _sensors_data} = Repo.insert(sensor_data)

      params = %{
        "entities" => [
          %{
            "entities" => [
              %{
                "name" => sensor.name,
                "type" => "Sensor",
                "action" => "delete",
                "id" => sensor.id,
                "parent_id" => project.id,
                "sensor_type_id" => sensor.sensor_type_id
              }
            ],
            "id" => project.id,
            "name" => "demo project",
            "slug" => "So53BFRd92wb",
            "type" => "Project",
            "version" => "1.0"
          }
        ],
        "id" => project.org_id,
        "org_id" => "#{project.org_id}",
        "name" => "DataKrew",
        "type" => "Organisation"
      }

      assert {:error, message} =
               EntityParser.update_project_hierarchy(current_user, project, params)

      assert message == "Something went wrong. Please verify your hirerachy tree."
    end

    test "successfully deletes respective leaf asset", %{
      project: project,
      asset_type: asset_type,
      current_user: current_user
    } do
      {:ok, asset} = create_root_asset(project, asset_type, current_user)

      params = %{
        "entities" => [
          %{
            "entities" => [
              %{
                "entities" => [],
                "name" => asset.name,
                "properties" => [],
                "type" => "Asset",
                "id" => asset.id,
                "parent_id" => project.id,
                "action" => "delete"
              }
            ],
            "id" => project.id,
            "name" => "demo project",
            "slug" => "So53BFRd92wb",
            "type" => "Project",
            "version" => "1.0"
          }
        ],
        "id" => project.org_id,
        "org_id" => "#{project.org_id}",
        "name" => "DataKrew",
        "type" => "Organisation"
      }

      assert {:ok, message} = EntityParser.update_project_hierarchy(current_user, project, params)
      assert is_nil(Repo.get(Asset, asset.id))
    end

    test "deletion of asset fails if its child sensor has data", %{
      project: project,
      asset_type: asset_type,
      current_user: current_user
    } do
      {:ok, asset} = create_root_asset(project, asset_type, current_user)

      {:ok, sensor} = Repo.insert(build(:sensor, parent_id: asset.id, parent_type: "Asset"))

      params = %{
        "entities" => [
          %{
            "entities" => [
              %{
                "entities" => [
                  %{
                    "name" => sensor.name,
                    "type" => "Sensor",
                    "id" => sensor.id,
                    "parent_id" => asset.id
                  }
                ],
                "name" => asset.name,
                "parent_id" => nil,
                "properties" => [],
                "type" => "Asset",
                "id" => asset.id,
                "action" => "delete"
              }
            ],
            "id" => project.id,
            "name" => "demo project",
            "slug" => "So53BFRd92wb",
            "type" => "Project",
            "version" => "1.0"
          }
        ],
        "id" => project.org_id,
        "org_id" => "#{project.org_id}",
        "name" => "DataKrew",
        "type" => "Organisation"
      }

      assert {:error, message} =
               EntityParser.update_project_hierarchy(current_user, project, params)

      assert message == [
               "Asset root asset tree contains sensors. Please delete associated sensors before deleting asset."
             ]
    end

    test "deletion of asset will not fail if it doesn't have sensors descendants", %{
      project: project,
      asset_type: asset_type,
      current_user: current_user
    } do
      {:ok, asset} = create_root_asset(project, asset_type, current_user)

      params = %{
        "entities" => [
          %{
            "entities" => [
              %{
                "entities" => [],
                "name" => asset.name,
                "parent_id" => nil,
                "properties" => [],
                "type" => "Asset",
                "id" => asset.id,
                "action" => "delete"
              }
            ],
            "id" => project.id,
            "name" => "demo project",
            "slug" => "So53BFRd92wb",
            "type" => "Project",
            "version" => "1.0"
          }
        ],
        "id" => project.org_id,
        "org_id" => "#{project.org_id}",
        "name" => "DataKrew",
        "type" => "Organisation"
      }

      assert {:ok, message} = EntityParser.update_project_hierarchy(current_user, project, params)
      assert is_nil(Repo.get(Asset, asset.id))
    end

    defp valid_hierarchy_tree_params(project, asset_type) do
      %{
        "entities" => [
          %{
            "entities" => [
              %{
                "entities" => [],
                "name" => "Ipoh Factory",
                "parent_id" => nil,
                "properties" => [],
                "type" => "Asset",
                "action" => "create",
                "asset_type_id" => asset_type.id
              }
            ],
            "id" => project.id,
            "name" => "demo project",
            "type" => "Project",
            "version" => "1.0"
          }
        ],
        "id" => project.org_id,
        "org_id" => "#{project.org_id}",
        "name" => "DataKrew",
        "type" => "Organisation"
      }
    end

    defp invalid_project_version_params(project) do
      %{
        "entities" => [
          %{
            "entities" => [],
            "id" => project.id,
            "name" => "demo project",
            "type" => "Project",
            "version" => "0.0"
          }
        ],
        "id" => project.org_id,
        "org_id" => "#{project.org_id}",
        "name" => "DataKrew",
        "type" => "Organisation"
      }
    end

    defp valid_asset_tree_with_sensors_creation_params(project, asset_type, sensor_type) do
      %{
        "entities" => [
          %{
            "entities" => [
              %{
                "entities" => [
                  %{
                    "name" => "Soil Moisture Sensor",
                    "type" => "Sensor",
                    "action" => "create",
                    "parent_id" => nil,
                    "sensor_type_id" => sensor_type.id
                  },
                  %{
                    "name" => "Moisture Sensor",
                    "type" => "Sensor",
                    "action" => "create",
                    "parent_id" => nil,
                    "sensor_type_id" => sensor_type.id
                  }
                ],
                "name" => "Ipoh Factory",
                "parent_id" => nil,
                "properties" => [],
                "type" => "Asset",
                "action" => "create",
                "asset_type_id" => asset_type.id
              }
            ],
            "id" => project.id,
            "name" => "demo project",
            "slug" => "So53BFRd92wb",
            "type" => "Project",
            "version" => "1.0"
          }
        ],
        "id" => project.org_id,
        "org_id" => "#{project.org_id}",
        "name" => "DataKrew",
        "type" => "Organisation"
      }
    end

    defp update_sensor_tree_params(project, asset, sensor) do
      %{
        "entities" => [
          %{
            "entities" => [
              %{
                "entities" => [
                  %{
                    "name" => "updated #{sensor.name}",
                    "type" => "Sensor",
                    "action" => "update",
                    "id" => sensor.id,
                    "parent_id" => asset.id
                  }
                ],
                "name" => asset.name,
                "parent_id" => nil,
                "properties" => [],
                "type" => "Asset",
                "id" => asset.id
              }
            ],
            "id" => project.id,
            "name" => "demo project",
            "slug" => "So53BFRd92wb",
            "type" => "Project",
            "version" => "1.0"
          }
        ],
        "id" => project.org_id,
        "org_id" => "#{project.org_id}",
        "name" => "DataKrew",
        "type" => "Organisation"
      }
    end

    defp create_root_asset(project, asset_type, current_user) do
      AssetModel.add_as_root(%{
        creator_id: current_user.id,
        name: "root asset",
        org_id: project.org_id,
        org_name: "demo org",
        owner_id: current_user.id,
        project_id: project.id,
        asset_type_id: asset_type.id,
        mapped_parameters: [%{name: "demo", data_type: "temp", unit: "123"}],
        metadata: [%{name: "demo", data_type: "temp", unit: "123"}],
        properties: ["temp", "current", "voltage"]
      })
    end

    defp create_child_sensors(asset) do
      sensor_manifest = build(:sensor, parent_id: asset.id, parent_type: "Asset")
      Repo.insert(sensor_manifest)
    end
  end
end
