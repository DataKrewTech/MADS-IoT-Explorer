defmodule AcqdatApiWeb.ElasticSearch.GatewayControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Factory.ElasticSearch.Gateway
  import AcqdatCore.Support.Factory

  describe "search_gateways/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn} do
      project = insert(:project)
      gateway = insert(:gateway, project: project, org: project.org)
      Gateway.create_index()
      Gateway.seed_gateway(gateway)
      :timer.sleep(1500)
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(
          conn,
          Routes.search_gateways_path(conn, :search_gateways, project.org.id, project.id),
          %{
            "label" => gateway.name
          }
        )

      result = conn |> json_response(403)
      Gateway.delete_index()
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "search with valid params", %{conn: conn} do
      project = insert(:project)
      gateway = insert(:gateway, project: project, org: project.org)
      Gateway.create_index()
      Gateway.seed_gateway(gateway)
      :timer.sleep(1500)

      conn =
        get(
          conn,
          Routes.search_gateways_path(conn, :search_gateways, project.org.id, project.id),
          %{
            "label" => gateway.name
          }
        )

      %{"gateways" => [rgateway]} = conn |> json_response(200)

      Gateway.delete_index()
      assert rgateway["access_token"] == gateway.access_token

      assert rgateway["uuid"] == gateway.uuid

      assert rgateway["id"] == gateway.id

      assert rgateway["parent_id"] == gateway.parent_id
      assert rgateway["parent_type"] == gateway.parent_type
      assert rgateway["slug"] == gateway.slug
      assert rgateway["channel"] == gateway.channel
    end

    test "search with no hits", %{conn: conn} do
      project = insert(:project)
      gateway = insert(:gateway)
      Gateway.create_index()
      Gateway.seed_gateway(gateway)
      :timer.sleep(1500)

      conn =
        get(
          conn,
          Routes.search_gateways_path(conn, :search_gateways, project.org.id, project.id),
          %{
            "label" => gateway.name
          }
        )

      result = conn |> json_response(200)
      Gateway.delete_index()

      assert result == %{
               "gateways" => []
             }
    end
  end

  describe "index gateways/2" do
    setup :setup_conn

    test "fails if authorization header not found", %{conn: conn} do
      project = insert(:project)
      Gateway.create_index()
      Gateway.seed_multiple_gateway(project)
      :timer.sleep(1500)
      bad_access_token = "avcbd123489u"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      conn =
        get(conn, Routes.gateway_path(conn, :index, project.org.id, project.id), %{
          "from" => 0,
          "page_size" => 1
        })

      result = conn |> json_response(403)
      Gateway.delete_index()
      assert result == %{"errors" => %{"message" => "Unauthorized"}}
    end

    test "index with valid params and multiple entries", %{conn: conn} do
      project = insert(:project)
      Gateway.create_index()
      [gateway1, gateway2, gateway3] = Gateway.seed_multiple_gateway(project)
      :timer.sleep(1500)

      conn =
        get(conn, Routes.gateway_path(conn, :index, project.org.id, project.id), %{
          "from" => 0,
          "page_size" => 3
        })

      %{"gateways" => gateways} = conn |> json_response(200)

      Gateway.delete_index()
      assert length(gateways) == 3
      [rgateway1, rgateway2, rgateway3] = gateways
      assert rgateway1["id"] == gateway1.id
      assert rgateway2["id"] == gateway2.id
      assert rgateway3["id"] == gateway3.id
    end
  end
end
