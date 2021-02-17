defmodule AcqdatApiWeb.ElasticSearch.GatewayControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  alias AcqdatCore.Factory.ElasticSearch.Gateway
  import AcqdatCore.Support.Factory

  describe "search_gateways/2" do
    setup :setup_conn

    setup do
      project = insert(:project)
      gateway = insert(:gateway, project: project, org: project.org)
      Gateway.create_index()
      Gateway.seed_gateway(gateway)
      :timer.sleep(2500)

      on_exit(fn ->
        Gateway.delete_index()
      end)

      [project: project, gateway: gateway]
    end

    test "fails if authorization header not found", %{
      conn: conn,
      project: project,
      gateway: gateway
    } do
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

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "search with valid params", %{conn: conn, project: project, gateway: gateway} do
      conn =
        get(
          conn,
          Routes.search_gateways_path(conn, :search_gateways, project.org.id, project.id),
          %{
            "label" => gateway.name
          }
        )

      %{"gateways" => [rgateway]} = conn |> json_response(200)

      assert rgateway["uuid"] == gateway.uuid
      assert rgateway["id"] == gateway.id
      assert rgateway["parent_id"] == gateway.parent_id
      assert rgateway["parent_type"] == gateway.parent_type
      assert rgateway["slug"] == gateway.slug
      assert rgateway["channel"] == gateway.channel
    end

    test "search with no hits", %{conn: conn, project: project} do
      conn =
        get(
          conn,
          Routes.search_gateways_path(conn, :search_gateways, project.org.id, project.id),
          %{
            "label" => "Random Name ?"
          }
        )

      result = conn |> json_response(200)

      assert result == %{
               "gateways" => [],
               "total_entries" => 0
             }
    end
  end

  describe "index gateways/2" do
    setup :setup_conn

    setup do
      project = insert(:project)
      Gateway.create_index()
      [gateway1, gateway2, gateway3] = Gateway.seed_multiple_gateway(project, 3)
      :timer.sleep(2500)

      on_exit(fn ->
        Gateway.delete_index()
      end)

      [project: project, gateway1: gateway1, gateway2: gateway2, gateway3: gateway3]
    end

    test "fails if authorization header not found", %{conn: conn, project: project} do
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

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "index with valid params and multiple entries", %{
      conn: conn,
      project: project,
      gateway1: gateway1,
      gateway2: gateway2,
      gateway3: gateway3
    } do
      conn =
        get(conn, Routes.gateway_path(conn, :index, project.org.id, project.id), %{
          "from" => 0,
          "page_size" => 3
        })

      %{"gateways" => gateways} = conn |> json_response(200)

      assert length(gateways) == 3
      [rgateway1, rgateway2, rgateway3] = gateways
      assert rgateway1["id"] == gateway1.id
      assert rgateway2["id"] == gateway2.id
      assert rgateway3["id"] == gateway3.id
    end
  end
end
