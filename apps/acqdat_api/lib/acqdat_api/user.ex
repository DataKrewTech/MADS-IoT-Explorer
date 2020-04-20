defmodule AcqdatApi.User do
  alias AcqdatCore.Model.User, as: UserModel

  def get(user_id) do
    UserModel.get(user_id)
  end
end
