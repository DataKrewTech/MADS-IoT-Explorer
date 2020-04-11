defmodule AcqdatApi.User do
  alias AcqdatCore.Model.User, as: UserModel
  import AcqdatApiWeb.Helpers

  def get(user_id) do
    UserModel.get(user_id)
  end
end
