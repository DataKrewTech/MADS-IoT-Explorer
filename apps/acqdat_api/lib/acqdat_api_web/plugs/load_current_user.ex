defmodule AcqdatApiWeb.Plug.LoadCurrentUser do
  import Plug.Conn
  alias AcqdatApiWeb.Guardian
  alias AcqdatCore.Repo
  alias AcqdatCore.Schema.RoleManagement.User

  def init(opts), do: opts

  def call(conn, _opts) do
    user = Repo.get(User, Guardian.Plug.current_resource(conn))
    assign(conn, :current_user, user)
  end
end
