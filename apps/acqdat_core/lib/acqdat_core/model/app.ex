defmodule AcqdatCore.Model.App do
  alias AcqdatCore.Schema.App
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.Helper, as: ModelHelper
  import Ecto.Query

  def get_all(%{page_size: page_size, page_number: page_number}) do
    App |> order_by(:name) |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all(%{page_size: page_size, page_number: page_number}, preloads) do
    # Team
    #   |> where([team], team.id in ^team_ids)
    #   |> Repo.all()
    paginated_app_data =
      App |> order_by(:name) |> Repo.paginate(page: page_number, page_size: page_size)

    app_data_with_preloads = paginated_app_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(app_data_with_preloads, paginated_app_data)
  end
end
