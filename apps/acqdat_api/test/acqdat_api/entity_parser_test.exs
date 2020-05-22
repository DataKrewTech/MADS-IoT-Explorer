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
      [project: project]
    end

    test "returns success and increments project version if hirerachy tree has been updated successfully",
         %{project: project} do
      params = %{
        "entities" => [
          %{
            "entities" => [
              %{
                "entities" => [],
                "name" => "Ipoh Factory",
                "parent_id" => nil,
                "properties" => [],
                "type" => "Asset",
                "action" => "create"
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

      assert {:ok, message} = EntityParser.update_project_hierarchy(project, params)
      updated_proj = Repo.get(Project, project.id)
      assert updated_proj.version == Decimal.add(project.version, "0.1")
    end

    test "returns errors when project version of the request does not match with current version",
         %{project: project} do
      params = %{
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

      assert {:error, message} = EntityParser.update_project_hierarchy(project, params)
      assert message == ["Please update your current tree version"]
    end

    test "create asset tree with Sensors as descendants", %{project: project} do
      params = %{
        "entities" => [
          %{
            "entities" => [
              %{
                "entities" => [
                  %{
                    "name" => "Soil Moisture Sensor",
                    "type" => "Sensor",
                    "action" => "create",
                    "parent_id" => nil
                  },
                  %{
                    "name" => "Moisture Sensor",
                    "type" => "Sensor",
                    "action" => "create",
                    "parent_id" => nil
                  }
                ],
                "name" => "Ipoh Factory",
                "parent_id" => nil,
                "properties" => [],
                "type" => "Asset",
                "action" => "create"
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

      assert length(Repo.all(Asset)) == 0
      assert length(Repo.all(Sensor)) == 0

      assert {:ok, message} = EntityParser.update_project_hierarchy(project, params)

      assert length(Repo.all(Asset)) == 1
      assert length(Repo.all(Sensor)) == 2
    end

    test "update sensor details of hirerachy", %{project: project} do
      {:ok, asset} =
        AssetModel.add_as_root(%{
          name: "root asset",
          org_id: project.org_id,
          org_name: "demo org",
          project_id: project.id
        })

      sensor_manifest = build(:sensor, parent_id: asset.id, parent_type: "Asset")
      {:ok, sensor} = Repo.insert(sensor_manifest)

      params = %{
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

      assert {:ok, message} = EntityParser.update_project_hierarchy(project, params)
      updated_sensor = Repo.get(Sensor, sensor.id)
      assert updated_sensor.name == "updated #{sensor.name}"
    end

    test "successfully deletes sensor without data", %{project: project} do
      sensor_manifest =
        build(:sensor, parent_id: project.id, parent_type: "Project", has_timesrs_data: false)

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

      assert {:ok, message} = EntityParser.update_project_hierarchy(project, params)
      assert is_nil(Repo.get(Sensor, sensor.id))
    end

    test "return errors if sensor contains data, in deletion", %{project: project} do
      sensor_manifest =
        build(:sensor, parent_id: project.id, parent_type: "Project", has_timesrs_data: true)

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

      assert {:error, message} = EntityParser.update_project_hierarchy(project, params)

      assert message == [
               "Sensor #{sensor.name} contains time-series data. Please delete sensors data before deleting sensor."
             ]
    end

    test "deletes respective leaf asset", %{project: project} do
      {:ok, asset} =
        AssetModel.add_as_root(%{
          name: "root asset",
          org_id: project.org_id,
          org_name: "demo org",
          project_id: project.id
        })

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

      assert {:ok, message} = EntityParser.update_project_hierarchy(project, params)
      assert is_nil(Repo.get(Asset, asset.id))
    end

    test "deletion of asset fails if its child sensor has data", %{project: project} do
      {:ok, asset} =
        AssetModel.add_as_root(%{
          name: "root asset",
          org_id: project.org_id,
          org_name: "demo org",
          project_id: project.id
        })

      {:ok, sensor} =
        Repo.insert(
          build(:sensor, parent_id: asset.id, parent_type: "Asset", has_timesrs_data: true)
        )

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

      assert {:error, message} = EntityParser.update_project_hierarchy(project, params)

      assert message == [
               "This hirerachy contains sensors data. Please delete all sensors data first."
             ]
    end

    test "deletion of asset will not fail if its child sensor has no data", %{project: project} do
      {:ok, asset} =
        AssetModel.add_as_root(%{
          name: "root asset",
          org_id: project.org_id,
          org_name: "demo org",
          project_id: project.id
        })

      {:ok, sensor} =
        Repo.insert(
          build(:sensor, parent_id: asset.id, parent_type: "Asset", has_timesrs_data: false)
        )

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

      assert {:ok, message} = EntityParser.update_project_hierarchy(project, params)
      assert is_nil(Repo.get(Asset, asset.id))
    end
  end
end
