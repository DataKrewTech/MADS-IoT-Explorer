defmodule AcqdatApi.TenantManagement.Requests do
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Model.RoleManagement.Requests
  alias AcqdatCore.Model.EntityManagement.Organisation
  alias AcqdatApi.RoleManagement.Invitation
  alias Ecto.Multi
  alias AcqdatCore.Repo

  defdelegate get_all(data), to: Requests

  def validate(%{"status" => status}, _current_user, request) when status == "reject" do
    case Requests.update(request, %{status: "rejected"}) do
      {:ok, _} ->
        {:ok, "Successfully Rejected the Request"}

      {:error, error} ->
        {:error, error}
    end
  end

  def validate(%{"status" => status}, current_user, request) when status == "accept" do
    Multi.new()
    |> Multi.run(:find_or_create_org, fn _, _changes ->
      Organisation.find_or_create_by_url(%{url: request.org_url, name: request.org_name})
    end)
    |> Multi.run(:create_invitation, fn _, %{find_or_create_org: org} ->
      %{id: role_id} = AcqdatCore.Model.RoleManagement.Role.get_role("orgadmin")

      metadata = %{
        "first_name" => request.first_name,
        "last_name" => request.last_name,
        "phone_number" => request.phone_number
      }

      attrs = %{
        email: request.email,
        type: "new_org_admin",
        org_id: org.id,
        role_id: role_id,
        metadata: Map.merge(metadata, request.user_metadata)
      }

      Invitation.create(attrs, current_user)
    end)
    |> Multi.run(:update_req_status, fn _, _ ->
      Requests.update(request, %{status: "accepted"})
    end)
    |> run_transaction()
  end

  defp run_transaction(multi_query) do
    result = Repo.transaction(multi_query)

    case result do
      {:ok, %{find_or_create_org: _org, create_invitation: invitation}} ->
        verify_invite({:ok, invitation})

      {:error, failed_operation, failed_value, _changes_so_far} ->
        case failed_operation do
          :find_or_create_org -> verify_error_changeset({:error, failed_value})
          :create_invitation -> verify_error_changeset({:error, failed_value})
          :update_req_status -> verify_error_changeset({:error, failed_value})
        end
    end
  end

  defp verify_invite({:ok, invitation}) do
    {:ok, invitation}
  end

  defp verify_invite({:error, invitation}) do
    {:error, extract_changeset_error(invitation)}
  end

  defp verify_error_changeset({:error, changeset}) do
    {:error, %{error: extract_changeset_error(changeset)}}
  end
end
