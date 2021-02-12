defmodule AcqdatApiWeb.ApiAccessAuth do
  import Plug.Conn
  import Ecto.Query
  alias AcqdatCore.Repo
  alias AcqdatApi.ExtractRoutes
  alias AcqdatCore.Schema.RoleManagement.{GroupUser, GroupPolicy, UserPolicy}
  alias AcqdatCore.Model.RoleManagement.User

  def init(default), do: default

  def call(conn, _params) do
    user_id = Guardian.Plug.current_resource(conn)

    user =
      case is_nil(user_id) do
        false ->
          {:ok, user} = User.get(String.to_integer(user_id))
          user |> Repo.preload([:role])

        true ->
          nil
      end

    case user == nil or (user.role.id == 1 and user.role.name == "admin") do
      true ->
        conn

      false ->
        case provide_access(conn, user_id) do
          true ->
            conn

          false ->
            conn
            |> put_status(401)
        end
    end
  end

  def provide_access(conn, user_id) do
    controller_name = Phoenix.Controller.controller_module(conn)
    action = Phoenix.Controller.action_name(conn) |> to_string

    [application, feature] =
      controller_name |> to_string |> String.split(".") |> truncate_controller

    group_ids = extract_user_groups(user_id)
    user_policies = extract_user_policies(user_id)

    case is_nil(List.first(group_ids)) do
      false ->
        group_id_present(group_ids, user_policies, action, application, feature)

      true ->
        user_id_present(user_policies, action, application, feature)
    end
  end

  defp group_id_present(group_ids, user_policies, action, application, feature) do
    group_policies = extract_policies(group_ids)

    policies =
      Enum.reduce(group_policies, [], fn policies, acc ->
        [policies.policy | acc]
      end) ++
        Enum.reduce(user_policies, [], fn policies, acc ->
          [policies.policy | acc]
        end)

    user_actions =
      Enum.reduce(policies, [], fn policy, acc ->
        acc ++ [policy |> Map.from_struct() |> Map.drop([:_id, :__meta__])]
      end)

    check_authentication(user_actions, action, application, feature)
  end

  defp user_id_present(user_policies, action, application, feature) do
    case is_nil(List.first(user_policies)) do
      true ->
        true

      false ->
        policies =
          Enum.reduce(user_policies, [], fn policies, acc ->
            [policies.policy | acc]
          end)

        user_actions =
          Enum.reduce(policies, [], fn policy, acc ->
            acc ++ [policy |> Map.from_struct() |> Map.drop([:_id, :__meta__])]
          end)

        check_authentication(user_actions, action, application, feature)
    end
  end

  def check_authentication(user_actions, action, application, feature) do
    case is_nil(List.first(user_actions)) do
      true ->
        false

      false ->
        single_action = List.first(user_actions)

        if single_action.action == action and single_action.app == application and
             single_action.feature == feature do
          true
        else
          user_actions = user_actions -- [single_action]
          check_authentication(user_actions, action, application, feature)
        end
    end
  end

  defp extract_user_groups(user_id) do
    query =
      from(user_group in GroupUser,
        where: user_group.user_id == ^user_id,
        select: user_group.user_group_id
      )

    Repo.all(query)
  end

  defp extract_user_policies(user_id) do
    query =
      from(user_policy in UserPolicy,
        where: user_policy.user_id == ^user_id,
        preload: [:policy]
      )

    Repo.all(query)
  end

  defp extract_policies(group_ids) do
    query =
      from(user_group in GroupPolicy,
        where: user_group.user_group_id in ^group_ids,
        preload: [:policy]
      )

    Repo.all(query)
  end

  defp truncate_controller([_, _, feature, controller_name]) do
    [trunc_controller, _] = controller_name |> String.split("Controller") |> return_trunc
    [feature, trunc_controller]
  end

  defp truncate_controller([_, feature, controller_name]) do
    [trunc_controller, _] = controller_name |> String.split("Controller") |> return_trunc
    [feature, trunc_controller]
  end

  defp return_trunc([trunc_name, _]) do
    [trunc_name, nil]
  end

  defp return_trunc([trunc_name]) do
    [trunc_name, nil]
  end
end
