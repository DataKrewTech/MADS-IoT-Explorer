defmodule AcqdatCore.Model.RoleManagement.RequestsTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.RoleManagement.Requests

  describe "create/1" do
    test "creates a request with supplied params" do
      params = %{
        first_name: "Tony",
        last_name: "Stark",
        email: "test@test.com",
        org_name: "org name",
        org_url: "org-url",
        phone_number: "123443545"
      }

      assert {:ok, _} = Requests.create(params)
    end

    test "fails if params is not present" do
      assert {:error, changeset} = Requests.create(%{})

      assert %{
               email: ["can't be blank"],
               first_name: ["can't be blank"],
               last_name: ["can't be blank"],
               org_name: ["can't be blank"],
               org_url: ["can't be blank"],
               phone_number: ["can't be blank"]
             } == errors_on(changeset)
    end
  end

  describe "update/2" do
    setup do
      request = insert(:request)
      [request: request]
    end

    test "updated a request status from pending to rejected", context do
      %{request: request} = context

      params = %{
        status: "rejected"
      }

      assert request.status == "pending"
      assert {:ok, request} = Requests.update(request, params)
      assert request.status == "rejected"
    end
  end

  describe "get/1" do
    test "returns a particular request record" do
      request = insert(:request)

      {:ok, result} = Requests.get(request.id)
      assert not is_nil(result)
      assert result.id == request.id
    end

    test "returns error if request not found" do
      {:error, result} = Requests.get(-1)
      assert result == "not found"
    end
  end

  describe "delete/1" do
    test "deletes a particular request record" do
      request = insert(:request)

      {:ok, result} = Requests.delete(request.id)
      assert result
      {:error, result} = Requests.get(request.id)
      assert result == "not found"
    end
  end

  describe "get_all" do
    test "returns requests data" do
      insert_list(5, :request)

      params = %{page_size: 10, page_number: 1}
      result = Requests.get_all(params)

      assert not is_nil(result)
      assert result.total_entries == 5
    end

    test "returns error not found, if no requests are present" do
      params = %{page_size: 10, page_number: 1}
      result = Requests.get_all(params)

      assert result.entries == []
      assert result.total_entries == 0
    end
  end
end
