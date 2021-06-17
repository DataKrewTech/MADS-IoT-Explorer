defmodule AcqdatApiWeb.Widgets.UserWidgetController do
  use AcqdatApiWeb, :authorized_controller
  alias AcqdatApi.Widgets.User
  alias AcqdatCore.Model.RoleManagement.User, as: UserModel
  alias AcqdatCore.Model.Widgets.User, as: UserWidgetModel
  alias AcqdatCore.Model.Widgets.Widget, as: WidgetModel
  alias AcqdatApiWeb.Widgets.UserWidgetErrorHelper
  import AcqdatApiWeb.Helpers
  import AcqdatApiWeb.Validators.Widgets.User

  plug :verify_widget_and_user when action in [:create]

  # plug :verify_user when action in [:index]

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_user_widget_params(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, _user_widget}} <- {:create, User.create(data)} do
          conn
          |> put_status(200)
          |> json(UserWidgetErrorHelper.confirm_message(:widget_added))
        else
          {:extract, {:error, error}} ->
            error = extract_changeset_error(error)
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message.error)
        end

      404 ->
        conn
        |> send_error(404, UserWidgetErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, UserWidgetErrorHelper.error_message(:unauthorized))
    end
  end

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}

        {:list, user_widget} =
          {:list,
           UserWidgetModel.get_all(data,
             user: :user_credentials,
             widget: []
           )}

        conn
        |> put_status(200)
        |> render("index.json", user_widget)

      404 ->
        conn
        |> send_error(404, UserWidgetErrorHelper.error_message(:resource_not_found))

      401 ->
        conn
        |> send_error(401, UserWidgetErrorHelper.error_message(:unauthorized))
    end
  end

  defp verify_widget_and_user(
         %{params: %{"widget_id" => widget_id, "user_id" => user_id}} = conn,
         _params
       ) do
    widget_id =
      case String.valid?(widget_id) do
        false -> widget_id
        true -> String.to_integer(widget_id)
      end

    {user_id, _} = Integer.parse(user_id)

    case WidgetModel.get(widget_id) do
      {:ok, widget} ->
        case UserModel.get(user_id) do
          {:ok, user} ->
            widget = Map.put_new(widget, :user, user)
            assign(conn, :widget, widget)

          {:error, _message} ->
            conn
            |> put_status(404)
        end

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
