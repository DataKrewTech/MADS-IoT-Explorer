defmodule VernemqMadsPluginTest do
  use ExUnit.Case
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory
  alias VernemqMadsPlugin.Account
  alias AcqdatCore.Schema.IotManager.BrokerCredentials
  alias AcqdatCore.Repo

  test "authenticate a gateway client if correct uuid and password" do
    gateway = insert(:gateway)

    params = %{
      entity_uuid: gateway.uuid,
      access_token: gateway.access_token,
      entity_type: "Gateway"
    }

    changeset = BrokerCredentials.changeset(%BrokerCredentials{}, params)
    Repo.insert!(changeset)

    result = Account.is_authenticated(gateway.uuid, gateway.access_token)
    assert result == :ok
  end

  test "authenticate fails if gateway not found" do
    result = Account.is_authenticated("xyz", "abc")
    assert result == {:error, "Invalid Credentials"}
  end

  test "authenticate fails if credentials are wrong" do
    gateway = insert(:gateway)

    params = %{
      entity_uuid: gateway.uuid,
      access_token: gateway.access_token,
      entity_type: "Gateway"
    }

    changeset = BrokerCredentials.changeset(%BrokerCredentials{}, params)
    Repo.insert!(changeset)

    result = Account.is_authenticated(gateway.uuid, "abc")
    assert result == {:error, "Invalid Credentials"}
  end

  test "authenticate for a project" do
    project = insert(:project)
    access_token = "abc1234"
    params = %{entity_uuid: project.uuid, access_token: access_token, entity_type: "Gateway"}
    changeset = BrokerCredentials.changeset(%BrokerCredentials{}, params)
    Repo.insert!(changeset)

    result = Account.is_authenticated(project.uuid, access_token)
    assert result == :ok
  end
end
