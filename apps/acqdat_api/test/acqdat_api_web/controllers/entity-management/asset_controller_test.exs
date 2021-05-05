defmodule AcqdatApiWeb.EntityManagement.AssetControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Model.EntityManagement.Asset
  import AcqdatCore.Support.Factory

  describe "show/2" do
    setup :setup_conn

    setup do
      asset = insert(:asset)

      [asset: asset]
    end

    test "fails if invalid token in in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        id: 3
      }

      conn = get(conn, Routes.assets_path(conn, :show, 1, 1, params.id))
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "asset with invalid asset id", %{conn: conn} do
      params = %{
        id: -1
      }

      conn = get(conn, Routes.assets_path(conn, :show, 1, 1, params.id))
      result = conn |> json_response(404)

      assert result == %{
               "detail" => "Either Asset or Project or Organisation or Asset Type with this ID doesn't exists",
               "source" => nil,
               "status_code" => 404,
               "title" => "Invalid entity ID"
             }
    end

    test "asset with valid id", %{conn: conn, asset: asset} do
      conn = get(conn, Routes.assets_path(conn, :show, asset.org.id, asset.project.id, asset.id))
      result = conn |> json_response(200)

      refute is_nil(result)

      assert Map.has_key?(result, "id")
      assert Map.has_key?(result, "name")
      assert Map.has_key?(result, "creator_id")
      assert Map.has_key?(result, "asset_type_id")
    end
  end

  describe "update/2" do
    setup :setup_conn

    setup do
      asset = insert(:asset)

      [asset: asset]
    end

    test "fails if invalid token in in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        asset: %{}
      }

      conn = put(conn, Routes.assets_path(conn, :update, 1, 1, 1, params))
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "updated asset successfully", %{conn: conn, asset: asset} do
      params = %{
        asset: %{
          name: "updated asset name"
        }
      }

      conn =
        put(
          conn,
          Routes.assets_path(conn, :update, asset.org.id, asset.project.id, asset.id, params)
        )

      metadata =
        Enum.reduce(asset.metadata, [], fn x, acc ->
          %{id: id, data_type: data_type, name: name, unit: unit, uuid: uuid, value: value} =
            Map.from_struct(x)

          changes = %{
            "name" => name,
            "data_type" => data_type,
            "unit" => unit,
            "uuid" => uuid,
            "id" => id,
            "value" => value
          }

          [changes | acc]
        end)

      result = conn |> json_response(200)

      assert result["description"] == asset.description
      assert result["id"] == asset.id
      assert result["properties"] == asset.properties
      assert result["name"] == asset.name
      assert result["metadata"] == Enum.reverse(metadata)
      assert result["type"] == "Asset"
      assert result["asset_type_id"] == asset.asset_type_id
      assert result["creator_id"] == asset.creator_id
      assert result["parent_id"] == asset.parent_id
    end
  end

  describe "create/2" do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      project = insert(:project)
      asset_type = insert(:asset_type)
      user = insert(:user)

      [org: org, project: project, asset_type: asset_type, user: user]
    end

    test "successfully create a root asset", context do
      %{
        asset_type: asset_type, project: project,
        org: org, project: project, user: user, conn: conn
      } = context

      params = %{
        "asset_type_id" => asset_type.id,
        "creator_id" => user.id,
        "description" => "",
        "metadata" => [],
        "name" => "Building 1",
        "org_id" => org.id,
        "parent_id" => nil,
        "parent_type" => "Project",
        "project_id" => project.id
      }

      conn = post(conn, Routes.assets_path(conn, :create, org.id, project.id), params)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end

    test "fails if two roots with same name are added", context do
      %{
        asset_type: asset_type, project: project,
        org: org, project: project, user: user, conn: conn
      } = context

      params = %{
        "asset_type_id" => asset_type.id,
        "creator_id" => user.id,
        "description" => "",
        "metadata" => [],
        "name" => "Building 1",
        "org_id" => org.id,
        "parent_id" => nil,
        "parent_type" => "Project",
        "project_id" => project.id
      }

      # created an asset
      post(conn, Routes.assets_path(conn, :create, org.id, project.id), params)

      # try again with the same params
      conn = post(conn, Routes.assets_path(conn, :create, org.id, project.id), params)
      result = conn |> json_response(400)

      assert result == %{
        "detail" => "name already taken by a root asset",
        "source" => %{"name" => ["name already taken by a root asset"]},
        "status_code" => 400,
        "title" => "Insufficient or not unique parameters"
      }
    end

    test "asset type create", %{conn: conn, org: org, user: user} do
      asset_manifest = build(:asset)
      project = insert(:project)
      asset_type = insert(:asset_type)

      data = %{
        name: asset_manifest.name,
        mapped_parameters: asset_manifest.mapped_parameters,
        metadata: asset_manifest.metadata,
        creator_id: user.id,
        project_id: project.id,
        asset_type_id: asset_type.id
      }

      conn = post(conn, Routes.assets_path(conn, :create, org.id, project.id), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end

    test "fails if authorization header not found", %{conn: conn, org: org} do
      bad_access_token = "qwerty1234567uiop"
      project = insert(:project)

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.assets_path(conn, :create, org.id, project.id), data)
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "fails if required params are missing", %{conn: conn, org: org} do
      asset = insert(:asset)
      project = insert(:project)
      insert(:asset_type)

      conn =
        post(conn, Routes.assets_path(conn, :create, org.id, project.id), %{
          asset_type_id: asset.asset_type_id
        })

      response = conn |> json_response(400)

      assert response == %{
               "detail" =>
                 "Parameters provided to perform current action is either not valid or missing or not unique",
               "source" => %{
                  "creator_id" => ["can't be blank"],
                  "name" => ["can't be blank"]
                },
               "status_code" => 400,
               "title" => "Insufficient or not unique parameters",
             }
    end
  end

  describe "create/2 child assets " do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      project = insert(:project)
      asset_type = insert(:asset_type, org: org, project: project)
      asset_type_child = insert(:asset_type, org: org, project: project)
      user = insert(:user)

      {:ok, root_asset} =
        Asset.add_as_root(%{
          name: "root asset",
          org_id: org.id,
          org_name: org.name,
          project_id: project.id,
          asset_type_id: asset_type.id,
          creator_id: user.id,
          metadata: [],
          mapped_parameters: [],
          owner_id: user.id,
          description: "Something",
          properties: []
        })

      [
        parent_entity: root_asset, org: org, project: project,
        asset_type: asset_type_child, user: user
      ]
    end

    test "inserts asssets successfully", context do
      %{
        parent_entity: parent, org: org, project: project,
        asset_type: asset_type, user: user, conn: conn
      } = context

      params = %{
        "asset_type_id" => asset_type.id,
        "creator_id" => user.id,
        "description" => "",
        "metadata" => [],
        "name" => "Building 1",
        "org_id" => org.id,
        "parent_id" => parent.id,
        "parent_type" => "Project",
        "project_id" => project.id
      }

      conn =
        post(conn, Routes.assets_path(conn, :create, org.id, project.id), params)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end

    test "returns error if duplicate names", context do
      %{
        parent_entity: parent, org: org, project: project,
        asset_type: asset_type, user: user, conn: conn
      } = context

      params = %{
        "asset_type_id" => asset_type.id,
        "creator_id" => user.id,
        "description" => "",
        "metadata" => [],
        "name" => "Building 1",
        "org_id" => org.id,
        "parent_id" => parent.id,
        "parent_type" => "Project",
        "project_id" => project.id
      }

      post(conn, Routes.assets_path(conn, :create, org.id, project.id),
        params)
      conn = post(conn, Routes.assets_path(conn, :create, org.id, project.id),
        params)
      response = conn |> json_response(400)
      assert response == %{
        "detail" => "Parameters provided to perform current action is either not valid or missing or not unique",
        "source" => %{
          "name" => ["name already taken under this hierarchy for this particular organisation, project and parent it is getting attached to."]
        },
        "status_code" => 400,
        "title" => "Insufficient or not unique parameters"
      }
    end
  end

  describe "delete/2" do
    setup :setup_conn

    test "asset delete", %{conn: conn, org: org} do
      asset = insert(:asset)
      project = insert(:project)
      conn = delete(conn, Routes.assets_path(conn, :delete, org.id, project.id, asset.id), %{})
      response = conn |> json_response(200)

      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "properties")
    end

    test "fails if invalid token in authorization header", %{conn: conn, org: org} do
      asset = insert(:asset)
      bad_access_token = "qwerty1234567qwerty"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        delete(conn, Routes.assets_path(conn, :delete, org.id, asset.project.id, asset.id), %{})

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end
  end

end
