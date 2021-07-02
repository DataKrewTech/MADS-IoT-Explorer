defmodule AcqdatApiWeb.IotManager.GatewayControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Test.Support.DataDump
  alias AcqdatCore.Model.EntityManagement.Asset
  alias AcqdatCore.Schema.EntityManagement.Asset, as: AssetSchema

  describe "create/2" do
    setup :setup_conn

    setup do
      project = insert(:project)
      org = insert(:organisation)

      [project: project, org: org]
    end

    test "gateway create", %{conn: conn, org: org, project: project} do
      gateway = build(:gateway)
      asset = insert(:asset)

      data = %{
        uuid: gateway.uuid,
        name: gateway.name,
        access_token: gateway.access_token,
        slug: gateway.slug,
        parent_id: asset.id,
        parent_type: "Asset",
        channel: gateway.channel,
        mapped_parameters: gateway.mapped_parameters
      }

      conn = post(conn, Routes.gateway_path(conn, :create, org.id, project.id), data)
      response = conn |> json_response(200)
      assert Map.has_key?(response, "parent_id")
      assert Map.has_key?(response, "parent_type")
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "org_id")
      assert Map.has_key?(response, "slug")
    end

    test "fails if authorization header not found", %{conn: conn, org: org, project: project} do
      bad_access_token = "qwerty1234567uiop"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = %{}
      conn = post(conn, Routes.gateway_path(conn, :create, org.id, project.id), data)
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end
  end

  describe "update/2" do
    setup :setup_conn

    setup do
      asset = insert(:asset)
      gateway = insert(:gateway)
      [asset: asset, gateway: gateway]
    end

    test "update gateway name", %{conn: conn, gateway: gateway} do
      data = Map.put(%{}, :name, "Water Plant")

      conn =
        put(
          conn,
          Routes.gateway_path(conn, :update, gateway.org_id, gateway.project_id, gateway.id),
          data
        )

      response = conn |> json_response(200)

      assert Map.has_key?(response, "parent_id")
      assert Map.has_key?(response, "parent_type")
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "org_id")
      assert Map.has_key?(response, "slug")
      assert response["name"] == "Water Plant"
    end

    test "update gateway parent to project", %{conn: conn, gateway: gateway} do
      data = %{
        parent_id: gateway.project_id,
        parent_type: "Project"
      }

      conn =
        put(
          conn,
          Routes.gateway_path(conn, :update, gateway.org_id, gateway.project_id, gateway.id),
          data
        )

      response = conn |> json_response(200)

      assert Map.has_key?(response, "parent_id")
      assert Map.has_key?(response, "parent_type")
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
      assert Map.has_key?(response, "org_id")
      assert Map.has_key?(response, "slug")
      assert response["parent_id"] == gateway.project_id
      assert response["parent_type"] == "Project"
    end

    test "fails if invalid token in authorization header", %{
      conn: conn,
      gateway: gateway
    } do
      bad_access_token = "qwerty12345678qwer"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      data = Map.put(%{}, :name, "Water Plant")

      conn =
        put(
          conn,
          Routes.gateway_path(conn, :update, gateway.org_id, gateway.project_id, gateway.id),
          data
        )

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end
  end

  describe "delete/2" do
    setup :setup_conn

    setup do
      asset = insert(:asset)
      gateway = insert(:gateway)
      [asset: asset, gateway: gateway]
    end

    test "gateway delete", %{conn: conn, gateway: gateway} do
      conn =
        delete(
          conn,
          Routes.gateway_path(conn, :delete, gateway.org_id, gateway.project_id, gateway.id)
        )

      response = conn |> json_response(200)
      assert Map.has_key?(response, "parent_id")
      assert Map.has_key?(response, "parent_type")
      assert Map.has_key?(response, "name")
      assert Map.has_key?(response, "id")
    end

    test "fails if invalid token in authorization header", %{
      conn: conn,
      gateway: gateway
    } do
      bad_access_token = "qwerty1234567qwerty"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        delete(
          conn,
          Routes.gateway_path(conn, :delete, gateway.org_id, gateway.project_id, gateway.id)
        )

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end
  end

  describe "show/2" do
    setup :setup_conn

    setup do
      gateway = insert(:gateway)
      [gateway: gateway]
    end

    test "returns a gateway", %{conn: conn, gateway: gateway} do
      conn =
        get(
          conn,
          Routes.gateway_path(conn, :show, gateway.org_id, gateway.project_id, gateway.id)
        )

      result = conn |> json_response(200)
      assert result["id"] == gateway.id
    end

    test "returns not found for invalid id", %{conn: conn, gateway: gateway} do
      conn = get(conn, Routes.gateway_path(conn, :show, gateway.org_id, gateway.project_id, -1))

      result = conn |> json_response(404)

      assert %{
               "detail" =>
                 "Either Gateway or Project or Organisation with this ID doesn't exists",
               "source" => nil,
               "status_code" => 404,
               "title" => "Invalid entity ID"
             } == result
    end
  end

  describe "data dump index/2" do
    setup :setup_conn

    setup do
      gateway = insert(:gateway)
      [gateway: gateway]
    end

    test "list data of a particular gateway", %{conn: conn, gateway: gateway} do
      params = %{
        "page_size" => 1,
        "page_number" => 1
      }

      DataDump.insert_multiple_datadumps(gateway)

      conn =
        get(
          conn,
          Routes.gateway_path(
            conn,
            :data_dump_index,
            gateway.org.id,
            gateway.project.id,
            gateway.id,
            params
          )
        )

      response = conn |> json_response(200)
      [data_dump] = response["data_dumps"]

      assert response ==
               %{
                 "data_dumps" => [
                   %{
                     "data" => %{
                       "axis_object" => %{
                         "lambda" => %{"alpha" => 24, "beta" => 25},
                         "x_axis" => 20,
                         "z_axis" => [22, 23]
                       },
                       "y_axis" => 21,
                       "project_id" => 1,
                       "timestamp" => 1_596_115_581,
                       "xyz" => %{}
                     },
                     "gateway_uuid" => gateway.uuid,
                     "inserted_timestamp" => data_dump["inserted_timestamp"]
                   }
                 ],
                 "page_number" => params["page_number"],
                 "page_size" => params["page_size"],
                 "total_entries" => response["total_entries"],
                 "total_pages" => response["total_pages"]
               }
    end

    test "fails if invalid token in authorization header", %{
      conn: conn,
      gateway: gateway
    } do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        "page_size" => 2,
        "page_number" => 1
      }

      conn =
        get(
          conn,
          Routes.gateway_path(
            conn,
            :data_dump_index,
            gateway.org.id,
            gateway.project.id,
            gateway.id,
            params
          )
        )

      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end
  end

  describe "all_gateways/2 " do
    setup :setup_conn

    setup do
      org = insert(:organisation)
      project_1 = insert(:project, org: org)
      project_2 = insert(:project, org: org)
      insert(:gateway, project: project_1, org: org)
      insert(:gateway, project: project_2, org: org)
      [org: org]
    end

    test "returns a list of all gateways", context do
      %{org: org, conn: conn} = context

      result = get(conn, Routes.gateway_path(conn, :all_gateways, org.id)) |> json_response(200)
      assert length(result["gateways"]) == 2
    end
  end

  describe "fetch_hierarchy" do
    setup :setup_conn
    setup :create_asset_tree

    test "returns the project hierarchy", context do
      %{org: org, conn: conn, project: project} = context

      result = conn
        |> get(Routes.gateway_path(conn, :fetch_project_tree, org.id, project.id))
        |> json_response(200)
      assert Map.has_key?(result, "entities")
      assert Map.has_key?(result, "type")
      assert length(result["entities"]) != 0
    end

  end

  #################### private functions #########################3

  defp create_asset_tree(_context) do
    org = insert(:organisation)
    project = insert(:project, org: org)
    asset_type = insert(:asset_type)
    user = insert(:user)

    asset_2 = build_asset_map("asset_2", org.id, org.name, project.id, user.id, asset_type.id)
    asset_3 = build_asset_map("asset_3", org.id, org.name, project.id, user.id, asset_type.id)
    asset_4 = build_asset_map("asset_4", org.id, org.name, project.id, user.id, asset_type.id)
    asset_5 = build_asset_map("asset_5", org.id, org.name, project.id, user.id, asset_type.id)

    # asset tree initialization
    # asset_1
    # |- asset_2
    #    |- asset_4
    #    |- asset_5
    # |- asset_3

    {:ok, asset_1} =
      Asset.add_as_root(
        build_asset_root_map("asset_1", org.id, org.name, project.id, user.id, asset_type.id)
      )

    {:ok, asset_2} = Asset.add_as_child(asset_1, asset_2, :child)
    Asset.add_as_child(asset_1, asset_3, :child)
    Asset.add_as_child(asset_2, asset_4, :child)
    Asset.add_as_child(asset_2, asset_5, :child)

    {:ok,
     %{
       project: project,
       org: org
     }}
  end

  defp build_asset_root_map(name, org_id, org_name, project_id, creator_id, asset_type_id) do
    %{
      name: name,
      org_id: org_id,
      org_name: org_name,
      project_id: project_id,
      creator_id: creator_id,
      asset_type_id: asset_type_id,
      metadata: [],
      mapped_parameters: [],
      owner_id: creator_id,
      properties: [],
      description: ""
    }
  end

  defp build_asset_map(name, org_id, _org_name, project_id, creator_id, asset_type_id) do
    %AssetSchema{
      name: name,
      org_id: org_id,
      project_id: project_id,
      creator_id: creator_id,
      asset_type_id: asset_type_id,
      metadata: [],
      mapped_parameters: [],
      owner_id: creator_id,
      properties: [],
      description: ""
    }
  end

end
