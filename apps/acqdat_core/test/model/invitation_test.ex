defmodule AcqdatCore.Model.InvitationTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.Invitation, as: InvitationModel

  describe "create_invitation/1" do
    test "creates a invitation with supplied params" do
      inviter = insert(:user)

      params = %{"email" => "test90@gmail.com", "inviter_id" => inviter.id}

      assert {:ok, _usersetting} = InvitationModel.create_invitation(params)
    end

    test "fails if inviter_id is not present" do
      params = %{"email" => "test90@gmail.com"}

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
end
