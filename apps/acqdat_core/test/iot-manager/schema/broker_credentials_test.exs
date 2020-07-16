defmodule AcqdatCore.Schema.IotManager.BrokerCredentialsTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory
  alias AcqdatCore.Schema.IotManager.BrokerCredentials
  alias AcqdatCore.Repo

  describe "changeset/2 " do
    setup do
      project = insert(:project)
      Repo
      gateway = insert(:gateway)
      [project: project, gateway: gateway]
    end

    test "returns invalid if empty params" do
      params = %{}
      %{valid?: validity} = BrokerCredentials.changeset(%BrokerCredentials{}, params)
      refute validity
    end

    test "returns a valid changeset", context do
      %{project: project} = context
      params = %{entity_uuid: project.uuid, access_token: "avcd1234",
        entity_type: "project"}
      %{valid?: validity} = BrokerCredentials.changeset(%BrokerCredentials{}, params)
      assert validity
    end

    test "returns invalid if unique constraint invalidated", context do
      %{project: project} = context
      params = %{entity_uuid: project.uuid, access_token: "avcd1234",
        entity_type: "project"}
      changeset = BrokerCredentials.changeset(%BrokerCredentials{}, params)
      assert {:ok, _creds} = Repo.insert(changeset)

      assert {:error, changeset} = Repo.insert(changeset)
      assert %{entity_uuid: ["has already been taken"]} == errors_on(changeset)
    end
  end
end
