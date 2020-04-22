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

  def get_by_email(email) do
    Repo.get_by(Invitation, email: email)
  end

  def get_by_token(token) do
    Repo.get_by(Invitation, token: token)
  end

  def delete(%Invitation{} = invitation) do
    Repo.delete(invitation)
  end
end
