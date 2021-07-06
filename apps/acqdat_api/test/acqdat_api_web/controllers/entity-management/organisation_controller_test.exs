defmodule AcqdatApiWeb.EntityManagement.OrganisationControllerTest do
  use ExUnit.Case, async: true
  use AcqdatApiWeb.ConnCase
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory

  describe "show/2" do
    setup :setup_conn

    test "fails if invalid token in in authorization header", %{conn: conn} do
      bad_access_token = "qwerty1234567qwerty12"

      conn =
        conn
        |> put_req_header("authorization", "Bearer #{bad_access_token}")

      params = %{
        id: 3
      }

      conn = get(conn, Routes.organisation_path(conn, :show, params.id))
      result = conn |> json_response(403)

      assert result == %{
               "detail" => "You are not allowed to perform this action.",
               "source" => nil,
               "status_code" => 403,
               "title" => "Unauthorized"
             }
    end

    test "organisation with invalid organisation id", %{conn: conn} do
      params = %{
        id: -1
      }

      conn = get(conn, Routes.organisation_path(conn, :show, params.id))
      result = conn |> json_response(404)

      assert result == %{
               "detail" => "Organisation with this ID doesn't exists",
               "source" => nil,
               "status_code" => 404,
               "title" => "Invalid entity ID"
             }
    end

    test "organisation with valid id", %{conn: conn, org: org} do
      params = %{
        id: org.id
      }

      conn = get(conn, Routes.organisation_path(conn, :show, params.id))
      result = conn |> json_response(200)

      assert result == %{
               "id" => org.id,
               "name" => org.name,
               "type" => "Organisation",
               "uuid" => org.uuid,
               "url" => org.url
             }
    end
  end
end
