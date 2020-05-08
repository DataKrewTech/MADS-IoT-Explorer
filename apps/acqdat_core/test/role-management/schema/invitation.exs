defmodule AcqdatCore.Schema.RoleManagement.InvitationTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  alias AcqdatCore.Schema.RoleManagement.Invitation
  import AcqdatCore.Support.Factory

  describe "changeset/2" do
    setup do
      inviter = insert(:user)

      [inviter: inviter]
    end

    test "returns a valid changeset", context do
      %{inviter: inviter} = context

      params = %{"email" => "test90@gmail.com", "inviter_id" => inviter.id}

      %{valid?: validity} = Invitation.changeset(%Invitation{}, params)
      assert validity
    end

    test "returns error changeset when inviter is not present" do
      params = %{"email" => "test90@gmail.com"}
      changeset = Invitation.changeset(%Invitation{}, params)

      assert %{inviter_id: ["can't be blank"]} == errors_on(changeset)
    end
  end
end
