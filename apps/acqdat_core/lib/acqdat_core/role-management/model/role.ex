defmodule AcqdatCore.Model.RoleManagement.Role do
  alias AcqdatCore.Schema.RoleManagement.Role
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.Helper, as: ModelHelper
  import Ecto.Query

  def get_all(%{page_size: page_size, page_number: page_number}) do
    Role |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all(%{page_size: page_size, page_number: page_number}, preloads) do
    paginated_role_data =
      Role |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    role_data_with_preloads = paginated_role_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(role_data_with_preloads, paginated_role_data)
  end

  def get_role_id(name) do
    query =
      from(role in Role,
        where: role.name == ^name,
        select: role.id
      )

    Repo.one(query)
  end
end
