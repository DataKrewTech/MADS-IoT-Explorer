defmodule AcqdatApi.RoleManagement.Requests do
  import AcqdatApiWeb.Helpers
  alias AcqdatCore.Model.RoleManagement.Requests
  alias AcqdatCore.Model.EntityManagement.Organisation
  alias AcqdatApi.RoleManagement.Invitation

  def validate(%{"status" => status}, _current_user, request) when status == "reject" do
    case Requests.update(request, %{status: "rejected"}) do
      {:ok, _} ->
        {:ok, "Successfully Rejected the Request"}

      {:error, error} ->
        {:error, error}
    end
  end

  def validate(%{"status" => status}, current_user, request) when status == "accept" do
    case Organisation.find_or_create_by_url(%{url: request.org_url, name: request.org_name}) do
      {:ok, org} ->
        "orgadmin"
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

      {:error, error} ->
        {:error, error}
    end
  end
end
