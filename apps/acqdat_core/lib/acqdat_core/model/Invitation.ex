defmodule AcqdatCore.Model.Invitation do
  @moduledoc """
  Exposes APIs for handling user related fields.
  """

  alias AcqdatCore.Schema.Invitation
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.Helper, as: ModelHelper
  import Ecto.Query

  def list_invitations() do
    Repo.all(Invitation)
  end

  def create_invitation(attrs \\ %{}) do
    %Invitation{}
    |> Invitation.changeset(attrs)
    |> Repo.insert()
  end

  def update_invitation(%Invitation{} = invitation, attrs \\ %{}) do
    invitation
    |> Invitation.update_changeset(attrs)
    |> Repo.update()
  end

  def update_invitation_token(%Invitation{} = invitation, attrs \\ %{}) do
    invitation
    |> Invitation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns a invitation by the supplied id.
  """
  def get(id) when is_integer(id) do
    case Repo.get(Invitation, id) do
      nil ->
        {:error, "not found"}

      invitation ->
        {:ok, invitation}
    end
  end

  def get_all(%{page_size: page_size, page_number: page_number, org_id: org_id}) do
    paginated_invitation_data =
      Invitation
      |> where([invitation], invitation.org_id == ^org_id)
      |> order_by(:email)
      |> Repo.paginate(page: page_number, page_size: page_size)

    invitation_data_with_preloads =
      paginated_invitation_data.entries |> Repo.preload([:role, :inviter])

    ModelHelper.paginated_response(invitation_data_with_preloads, paginated_invitation_data)
  end

  def get_by_email(email) do
    Repo.get_by(Invitation, email: email)
  end

  def get_by_token(token) do
    Repo.get_by(Invitation, token: token, token_valid: true)
  end

  def delete(%Invitation{} = invitation) do
    Repo.delete(invitation)
  end
end
