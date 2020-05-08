defmodule AcqdatCore.Model.RoleManagement.InvitationTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.RoleManagement.Invitation, as: InvitationModel

  describe "create_invitation/1" do
    setup do
      org = insert(:organisation)
      role = insert(:role)
      [org: org, role: role]
    end

    test "creates a invitation with supplied params", context do
      %{org: org, role: role} = context
      inviter = insert(:user)

      params = %{
        "email" => "test90@gmail.com",
        "inviter_id" => inviter.id,
        "org_id" => org.id,
        "role_id" => role.id
      }

      assert {:ok, _usersetting} = InvitationModel.create_invitation(params)
    end

    test "fails if inviter_id is not present", context do
      %{org: org, role: role} = context
      params = %{"email" => "test90@gmail.com", "org_id" => org.id, "role_id" => role.id}

      assert {:error, changeset} = InvitationModel.create_invitation(params)
      assert %{inviter_id: ["can't be blank"]} == errors_on(changeset)
    end
  end

  describe "get_by_email/1" do
    test "returns a particular invitation record" do
      invitation = insert(:invitation)

      result = InvitationModel.get_by_email(invitation.email)
      assert not is_nil(result)
      assert result.email == invitation.email
    end

    test "returns error not found, if setting is not present" do
      result = InvitationModel.get_by_email("dummy_email@email.email")
      assert result == nil
    end
  end

  describe "delete/1" do
    test "deletes a particular invitation record" do
      invitation = insert(:invitation)
      result = InvitationModel.get_by_email(invitation.email)
      assert not is_nil(result)
      {:ok, result} = InvitationModel.delete(invitation)
      assert result
      result = InvitationModel.get_by_email(invitation.email)
      assert is_nil(result)
    end
  end

  describe "get_all" do
    test "returns invitations data" do
      invitation = insert(:invitation)

      params = %{page_size: 10, page_number: 1, org_id: invitation.org_id}
      result = InvitationModel.get_all(params)

      assert not is_nil(result)
      assert result.total_entries == 1
    end

    test "returns error not found, if teams are not present" do
      params = %{page_size: 10, page_number: 1, org_id: 1}
      result = InvitationModel.get_all(params)

      assert result.entries == []
      assert result.total_entries == 0
    end
  end
end
