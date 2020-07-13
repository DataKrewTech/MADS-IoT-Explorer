defmodule VernemqMadsPluginTest do
  use ExUnit.Case
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory
  alias VernemqMadsPlugin.Account

  test "authenticate a client if correct uuid and password" do
    gateway = insert(:gateway)
    result = Account.is_authenticated?(gateway.uuid, gateway.access_token)
    assert result
  end

  test "authenticate fails if gateway not found" do
    result = Account.is_authenticated?("xyz", "abc")
    refute result
  end

  test "authenticate fails if credentials are wrong" do
    gateway = insert(:gateway)
    result = Account.is_authenticated?(gateway.uuid, "abc")
    refute result
  end

end
