defmodule AcqdatCore.Schema.RoleManagement.RequestsTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  alias AcqdatCore.Schema.RoleManagement.Requests

  describe "changeset/2" do
    test "returns error changeset on empty params" do
      changeset = Requests.changeset(%Requests{}, %{})

      assert %{
               email: ["can't be blank"],
               first_name: ["can't be blank"],
               last_name: ["can't be blank"],
               org_name: ["can't be blank"],
               org_url: ["can't be blank"],
               phone_number: ["can't be blank"]
             } == errors_on(changeset)
    end

    test "returns a valid changeset" do
      params = %{
        "email" => "test90@gmail.com",
        "first_name" => "demo",
        "last_name" => "demo",
        "org_name" => "org name",
        "org_url" => "org-url",
        "phone_number" => "123443545"
      }

      %{valid?: validity} = Requests.changeset(%Requests{}, params)
      assert validity
    end

    test "returns error if email regex not matched" do
      params = %{
        first_name: "Tony",
        last_name: "Stark",
        email: "tonystarkindustries.com",
        org_name: "org name",
        org_url: "org-url",
        phone_number: "123443545"
      }

      changeset = Requests.changeset(%Requests{}, params)

      assert %{
               email: ["has invalid format"]
             } == errors_on(changeset)
    end
  end
end
