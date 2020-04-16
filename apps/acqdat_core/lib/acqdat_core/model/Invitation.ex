defmodule AcqdatCore.Model.Invitation do
  @moduledoc """
  Exposes APIs for handling user related fields.
  """

  alias AcqdatCore.Schema.Invitation
  alias AcqdatCore.Repo

  def list_invitations() do
    Repo.all(Invitation)
  end

  def create_invitation(attrs \\ %{}) do
    %Invitation{}
    |> Invitation.changeset(attrs)
    |> Repo.insert()
  end
end
